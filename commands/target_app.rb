module TargetApp
  URL = 'http://botnet-target.herokuapp.com'
  EMAIL = 'somedouche@isuck.com'
  PASSWORD = 'helloworld'

  def login(agent, state)
    # Use the Mechanize agent to login to the website
    raise 'Not yet implemented!'

    state[:login_user] = {user_id: user_id, status: agent.page.code}
  end

  def go_to_homepage(agent, state)
    home_page = agent.get(URL)

    state[:go_to_homepage] = {status: agent.page.code}
  end

  def go_to_posts_index(agent, state)
    # Use the Mechanize agent to go to the posts#index
    posts_index = agent.get("/posts")

    state[:go_to_posts_index] = {status: agent.page.code}
  end

  def go_to_post_one(agent, state)
    # Use the Mechanize agent to go to the posts#show
    post_one = agent.get("/posts/1")

    state[:go_to_posts_one] = {status: agent.page.code}
  end

  def go_to_about(agent, state)
    # Use the Mechanize agent to go to the static_pages#about
    about_page = agent.get('/about')

    state[:go_to_about] = {status: agent.page.code}
  end

  def create_post(agent, state)
    # Use the Mechanize agent to go to create a post
    raise 'Not yet implemented!'

    state[:create_post] = {post: post, status: agent.page.code}
  end

  def create_comment(agent, state)
    # depends on login_user, create_post
    # Use the Mechanize agent to create a comment
    raise 'Not yet implemented!'

    state[:create_comment] = {comment: comment, status: agent.page.code}
  end
end