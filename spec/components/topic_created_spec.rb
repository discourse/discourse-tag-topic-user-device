# frozen_string_literal: true

require "rails_helper"

describe Topic do
  let(:user) { Fabricate(:user) }
  let(:pc) do
    PostCreator.new(
      user,
      raw: "this is the new content for my topic",
      title: "this is my new topic title",
    )
  end

  context "by default" do
    it "does nothing with no tags" do
      _post = pc.create
      expect(_post.topic.tags).to be_empty
    end
  end

  context "it works" do
    before do
      Tag.create(name: "mac")
      Tag.create(name: "windows")
    end

    it "does nothing if user has no mac/windows history" do
      _post = pc.create
      expect(_post.topic.tags).to be_empty
    end

    it "can add mac tag" do
      UserAuthToken.create(
        auth_token: "nada",
        prev_auth_token: "nada",
        auth_token_seen: true,
        user_agent:
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:81.0) Gecko/20100101 Firefox/81.0",
        client_ip: "127.0.0.1",
        user_id: user.id,
        rotated_at: 1.day.ago,
        created_at: 1.day.ago,
        updated_at: 1.day.ago,
      )

      _post = pc.create

      expect(_post.topic.tags).to include(Tag.where(name: "mac").first)
      expect(_post.topic.tags).not_to include(Tag.where(name: "windows").first)
    end

    it "can add windows tag" do
      UserAuthToken.create(
        auth_token: "nadawin",
        prev_auth_token: "nadawin",
        auth_token_seen: true,
        user_agent:
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36",
        client_ip: "127.0.0.1",
        user_id: user.id,
        rotated_at: 1.day.ago,
        created_at: 1.day.ago,
        updated_at: 1.day.ago,
      )

      _post = pc.create

      expect(_post.topic.tags).to include(Tag.where(name: "windows").first)
      expect(_post.topic.tags).not_to include(Tag.where(name: "mac").first)
    end

    it "can add both" do
      UserAuthToken.create(
        auth_token: "nada",
        prev_auth_token: "nada",
        auth_token_seen: true,
        user_agent:
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:81.0) Gecko/20100101 Firefox/81.0",
        client_ip: "127.0.0.1",
        user_id: user.id,
        rotated_at: 1.day.ago,
        created_at: 1.day.ago,
        updated_at: 1.day.ago,
      )

      UserAuthToken.create(
        auth_token: "nadawin",
        prev_auth_token: "nadawin",
        auth_token_seen: true,
        user_agent:
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36",
        client_ip: "127.0.0.1",
        user_id: user.id,
        rotated_at: 1.day.ago,
        created_at: 1.day.ago,
        updated_at: 1.day.ago,
      )

      _post = pc.create

      expect(_post.topic.tags).to include(Tag.where(name: "windows").first)
      expect(_post.topic.tags).to include(Tag.where(name: "mac").first)
    end

    it "does not apply tag for staff user" do
      user.update!(admin: true)

      UserAuthToken.create(
        auth_token: "nadawin",
        prev_auth_token: "nadawin",
        auth_token_seen: true,
        user_agent:
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36",
        client_ip: "127.0.0.1",
        user_id: user.id,
        rotated_at: 1.day.ago,
        created_at: 1.day.ago,
        updated_at: 1.day.ago,
      )

      _post = pc.create

      expect(_post.topic.tags).not_to include(Tag.where(name: "windows").first)
      expect(_post.topic.tags).not_to include(Tag.where(name: "mac").first)
    end
  end
end
