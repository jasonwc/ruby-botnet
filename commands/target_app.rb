module TargetApp
  URL = 'http://botnet-target.herokuapp.com'
  EMAIL = 'json@masteryconnect.com'
  PASSWORD = 'helloworld'

  def go_to_homepage(agent, state)
    home_page = agent.get(URL)

    state[:go_to_homepage] = {status: agent.page.code}
  end

  def login(agent, state)
    # Use the Mechanize agent to login to the website
    raise 'Not yet implemented!'

    state[:login_user] = {user_id: user_id, status: agent.page.code}
  end

  def go_to_posts_index(agent, state)
    # depends on login
    # Use the Mechanize agent to go to the posts#index
    raise 'Not yet implemented!'

    state[:go_to_posts_index] = {status: agent.page.code}
  end

  def create_post(agent, state)
    # depends on login
    # Use the Mechanize agent to go to create a post
    raise 'Not yet implemented!'

    state[:create_post] = {post: post, status: agent.page.code}
  end

  def create_comment(agent, state)
    # depends on login, create_post
    # Use the Mechanize agent to create a comment
    raise 'Not yet implemented!'

    state[:create_comment] = {comment: comment, status: agent.page.code}
  end
end