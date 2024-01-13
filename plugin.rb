# frozen_string_literal: true

# name: discourse-tag-topic-user-device
# about: Tag topics with the user's OS via their user agent.
# version: 1.0
# authors: pmusaraj
# url: https://github.com/discourse/discourse-tag-topic-user-device

enabled_site_setting :discourse_tag_topic_user_device_enabled

PLUGIN_NAME ||= "DiscourseTagTopicUserDevice"

after_initialize do
  DiscourseEvent.on(:topic_created) do |topic, opts, user|
    next if !topic.regular? || !user || !user.human? || user.staff?

    mac = Tag.where(name: "mac").first
    windows = Tag.where(name: "windows").first

    next if !mac && !windows

    user_agents = user&.user_auth_tokens.pluck(:user_agent)

    oss = Set.new
    user_agents.each { |ua| oss << BrowserDetection.os(ua) }
    oss.select! { |os| %i[macos windows].include? os }

    ActiveRecord::Base.transaction do
      topic.tags.reload
      topic.tags << mac if mac && oss.include?(:macos) && !topic.tags.include?(mac)
      topic.tags << windows if windows && oss.include?(:windows) && !topic.tags.include?(windows)

      topic.save!
    end
  end
end
