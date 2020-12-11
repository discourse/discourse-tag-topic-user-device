# frozen_string_literal: true

# name: DiscourseTagTopicUserDevice
# about: Tag topics with Mac/Windows via their user agent.
# version: 0.1
# authors: pmusaraj
# url: https://github.com/pmusaraj

enabled_site_setting :discourse_tag_topic_user_device_enabled

PLUGIN_NAME ||= 'DiscourseTagTopicUserDevice'

after_initialize do
  DiscourseEvent.on(:topic_created) do |topic, opts, user|

    next if !topic.regular? || !user || !user.human? || user.staff?

    mac = Tag.where(name: 'mac').first
    windows = Tag.where(name: 'windows').first

    next if !mac && !windows

    user_agents = user&.user_auth_tokens.pluck(:user_agent)

    oss = Set.new
    user_agents.each do |ua|
      oss << BrowserDetection.os(ua)
    end
    oss.select! {|os| [:macos, :windows].include? os }

    topic.tags << mac if mac && oss.include?(:macos)
    topic.tags << windows if windows && oss.include?(:windows)

    topic.save!
  end
end
