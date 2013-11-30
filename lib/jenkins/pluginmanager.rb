#!/usr/bin/env ruby
# vim: tabstop=2 expandtab shiftwidth=2

require 'jenkins/pageobject'

module Jenkins
  class PluginManager < PageObject
    def initialize(*args)
      super(*args)
      @updated = false
    end

    def url
      @base_url + "/pluginManager"
    end

    def open
      visit url
    end

    def check_for_updates
      visit "#{url}/checkUpdates"

      wait_for("//span[@id='completionMarker' and text()='Done']", timeout: 40)

      @updated = true
      # This is totally arbitrary, it seems that the Available page doesn't
      # update properly if you don't sleep a bit
      sleep 5
    end

    def installed?(name)
      visit "#{url}/installed"
      page.has_xpath?("//input[@url='plugin/#{name}']")
    end

    def install_plugin!(name)

      return if installed?(name)

      unless @updated
        check_for_updates
      end

      visit "#{url}/available"
      first(:xpath, "//input[starts-with(@name,'plugin.#{name}.')]").set(true)
      find_button('Install').click

      start = Time.now.to_i

      wait_for_cond(timeout: 180, message: "Plugin installation took too long") do
        failed = $jenkins.log.has_logged? /IOException: (?<msg>Failed to download from .*\.hpi)/
        raise failed[:msg] if failed
        installed? name
      end

      installation_time = Time.now.to_i - start
      if installation_time > 30
        puts "Plugin installation took #{installation_time} seconds"
      end

      # TODO install several plugins in one step so will have to wait and
      # restart at most once per scenario
      visit '/updateCenter'
      if page.has_content?('Jenkins needs to be restarted for the update to take effect')
        raise RestartNeeded.new
      end
    end

    class RestartNeeded < Exception
    end
  end
end
