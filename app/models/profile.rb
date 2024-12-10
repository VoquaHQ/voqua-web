BANNED_WORDS = [
    "~", "about", "admin", "api", "app", "archive", "auth", "blog", "cart",
    "categories", "category", "checkout", "comment", "comments",
    "community", "contact", "dashboard", "download", "edit", "faq",
    "feed", "forum", "help", "home", "index", "inbox", "info", "login",
    "logout", "marketplace", "messages", "new", "news", "notification",
    "notifications", "password", "privacy", "profile", "register",
    "root", "search", "settings", "signup", "support", "terms",
    "user", "username", "users",
    "account", "activity", "billing", "calendar", "campaign", "chat",
    "client", "clients", "connect", "console", "contact", "contacts",
    "create", "demo", "developer", "developers", "events", "explore",
    "file", "files", "group", "groups", "history", "invite",
    "inventory", "issue", "issues", "jobs", "language", "languages",
    "legal", "license", "list", "lists", "manage", "manager", "media",
    "member", "members", "moderator", "moderators", "module", "modules",
    "news", "organization", "organizations", "overview", "partner",
    "partners", "password", "plans", "plugin", "plugins", "policy",
    "portal", "project", "projects", "repo", "repository", "resources",
    "roadmap", "schedule", "search", "security", "service", "services",
    "session", "sessions", "shop", "solution", "solutions", "status",
    "store", "subscribe", "subscription", "subscriptions", "team",
    "teams", "tool", "tools", "topic", "topics", "tutorial", "tutorials",
    "update", "upload", "user", "users", "web", "webmaster", "widget",
    "widgets",
    "beta", "comingsoon", "dashboard", "docs", "documentation", "email",
    "feedback", "forgot", "invite", "launch", "map", "mapping",
    "me", "my", "myaccount", "oauth", "page", "pages", "plans",
    "portfolio", "post", "posts", "pricing",
    "rails", "redirect",
    "recede_historical_location", "resume_historical_location", "refresh_historical_location",
    "register", "request", "reset", "review", "reviews",
    "rss", "save", "search", "service", "session",
    "signup", "signin", "signout", "static", "status",
    "story", "subscribe", "subscription", "test", "tests",
    "thankyou", "tos", "trial", "unsubscribe", "up", "version",
    "versions", "watch", "web", "webhooks", "wiki"
  ].freeze

class Profile < ApplicationRecord
  has_many :user_profiles, dependent: :destroy
  has_many :owned_ballots, class_name: "Ballot", dependent: :destroy
  has_many :ballot_memberships, dependent: :destroy
  has_many :ballots, through: :ballot_memberships

  has_one :user, class_name: "User", foreign_key: "main_profile_id"

  validates :handle, length: { in: 1..20, if: -> { !handle.nil? } }

  validate :handle_does_not_contain_banned_words

  before_validation :nullify_blank_handle

  def handle_does_not_contain_banned_words
    return if handle.nil?

    if BANNED_WORDS.any? { |word| handle.downcase == word }
      errors.add(:handle, "has already been taken")
    end
  end

  private

  def nullify_blank_handle
    self.handle = nil if handle.blank?
  end
end
