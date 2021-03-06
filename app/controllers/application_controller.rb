class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  include Pundit

  # Pundit: white-list approach.
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # Uncomment when you *really understand* Pundit!
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # def user_not_authorized
  #   flash[:alert] = "You are not authorized to perform this action."
  #   redirect_to(root_path)
  # end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def relative_position(item, array)
    # returns a value between 1 and -1
    # 1 for first item, 0 for last item
    # equal distances between items
    if array.size <= 1
      return 0
    elsif array.size.odd?
      median = array.size / 2
      increment = 1.0 / median
      value = (array.index(item) - median) * (- increment)
      value
    else
      increment = 2.0 / (array.size - 1)
      value = 1 - (array.index(item) * increment)
    end
  end

  def relative_diff(item, array1, array2)
    # calculates the difference of index between item in two arrays
    # if item not in one array, gives the index in the other
    # if item not in any array, returns 0
    if array1.include?(item) && array2.include?(item)
      return (relative_position(item, array1) - relative_position(item, array2)).abs
    elsif array1.include?(item)
      return relative_position(item, array1)
    elsif array2.include?(item)
      return relative_position(item, array2)
    else
      return nil
    end
  end

  def default_url_options
    { host: ENV["HOST"] || "localhost:3000" }
  end

  def euclidean_distance(array1, array2)
    # gives the vector distance of two arrays
    # item is axis, index is value
    if array1 & array2 == []
      return nil
    else
      all_distances = []
      array1.each do |item|
        # calculates distance for all items in array 1
        distance = relative_diff(item, array1, array2)
        all_distances << distance
      end
      (array2 - array1).each do |item|
        distance = relative_diff(item, array1, array2)
        all_distances << distance
      end
      sum_of_squared_distances = 0
      all_distances.each do |distance|
        sum_of_squared_distances += distance**2
      end
      return Math.sqrt(sum_of_squared_distances)
    end
  end

  def relevance(array1, array2)
    distance = euclidean_distance(array1, array2)
    intersection_size = (array1 & array2).size
    unless distance == nil
      relevance = intersection_size / distance
      return relevance
    end
    return nil
  end

  def weightedaverage(values, weights)
    raise "Arrays have different sizes. Cannot compute weighted average" if values.length != weights.length
    sum_product = 0
    sum_weights = 0
    (0..values.length - 1).to_a.each do |counter|
      sum_product += values[counter] * weights[counter]
      sum_weights += weights[counter]
    end
    return sum_product / sum_weights
  end

  def ratings_count(user)
    # gets the amount of movies rated by a user
    count = Point.all.select{ |point| point.user_id == user.id}.count
    return count
  end

  def user_level(ratings)
    # stablishes a "level" according to the number of ratings by a user
    # returns rank, a custom message and the next user ranking
    message1 = "You've rated #{ratings} movies."
    rank = "Noobie"
    next_rank = "Beginner (#{3 - ratings} more movie#{ratings < 2 ? 's' : ''})"
    case ratings
    when 0
      message1 = "You haven't rated any movies yet. :/"
      message2 = "Rate 3 movies to get your first recommendations."
    when 1..2
      message2 = "Rate #{3 - ratings} more movie#{ratings < 2 ? 's' : ''} to get your first recommendations."
    when 3..9
      rank = "Beginner"
      next_rank = "Film Student (#{10 - ratings} more movie#{ratings < 9 ? 's' : ''})"
      message2 = "Well done! Rate more movies to get better recommendations."
    when 10..49
      rank = "Film Student"
      next_rank = "Cinephile (#{50 - ratings} more movie#{ratings < 49 ? 's' : ''})"
      message2 = "Keep going to get even better recommendations!"
    else
      rank = "Cinephile"
      message2 = "Wow! You're on the right track. Keep rating!"
      next_rank = "None. You're a top user."
    end
    return [rank, next_rank, message1, message2]
  end
end
