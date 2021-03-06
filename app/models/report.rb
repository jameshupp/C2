class Report < ActiveRecord::Base
  belongs_to :user
  has_many :subscriptions, class_name: ScheduledReport, foreign_key: :report_id

  visitable # Used to track user visit associated with processed report

  def client_query
    @_client_query ||= ProposalFieldedSearchQuery.new(query[user.client_model_slug])
  end

  def text_query
    query["text"]
  end

  def humanized_query
    query["humanized"]
  end

  def query_string
    if text_query.present? && client_query.present?
      "(#{text_query}) AND (#{client_query})"
    elsif client_query.present?
      "#{client_query}"
    else
      text_query
    end
  end

  def query
    super || default_query
  end

  def default_query
    { "humanized" => "", "text" => "" }
  end

  def url
    allowed_params = ["text", user.client_model_slug, "from", "size"]
    params = query.slice(*allowed_params)
    params[:report] = id
    "#{Rails.application.routes.url_helpers.query_proposals_path}?#{params.to_query}"
  end

  def run
    client_param_name = user.client_model_slug
    fielded_query = query[user.client_model_slug]
    params = ActionController::Parameters.new(text: text_query, client_param_name => fielded_query)
    ProposalListingQuery.new(user, params).query
  end

  def subscribed?(some_user)
    subscriptions.where(user: some_user).any?
  end

  def subscription_for(some_user)
    subscriptions.find_by(user: some_user)
  end

  def self.sql_for_user(user)
    <<-SQL.gsub(/^ {6}/, "")
      SELECT * FROM reports
      WHERE user_id=#{user.id}
        OR (
          shared=true AND user_id IN (
            SELECT id FROM users WHERE client_slug='#{user.client_slug}'
          )
        )
    SQL
  end

  def self.for_user(user)
    sql = sql_for_user(user)
    self.find_by_sql(sql)
  end
end
