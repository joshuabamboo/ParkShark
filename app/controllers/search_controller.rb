class SearchController < ApplicationController
  def nearby
    sort_type = params[:sort_type] if params[:sort_type]
    start_time_filter = parse_time(:beginning_time) if params[:listing]
    end_time_filter = parse_time(:ending_time) if params[:listing]
    price_filter = params[:price] if params[:price] && params[:price].size > 0
    if params[:q] && params[:radius]
      @spots = Spot.near(params[:q], params[:radius])
    elsif params[:q]
      @spots = Spot.near(params[:q], Spot.default_search_distance)
    else
      @spots = Spot.near(current_location, Spot.default_search_distance)
    end

    if price_filter && start_time_filter && end_time_filter
      @spots = filter_price(@spots, price_filter, start_time_filter, end_time_filter)
    elsif start_time_filter && end_time_filter
      @spots = filter_time(@spots, start_time_filter, end_time_filter)
    end

    @spots = sort(@spots, sort_type) if sort_type
    @title = 'Nearby Parking Spots'
    @subtitle = 'The nearest parking spots are below!'
  end

  private

  def spots_with_listings(spots_array)
    @spots.select{|spot| spot.available_listings.size > 0}
  end

  def current_location
    if current_user
      [current_user.latitude, current_user.longitude]
    else
      [session[:latitude], session[:longitude]]
    end
  end

  def filter_price(spots_array, price_filter, start_time_filter, end_time_filter)
    spots_array.select do |spot|
      spot.available_listings.any? do |listing|
        listing.price <= price_filter.to_i && listing.is_available_between(start_time_filter, end_time_filter)
      end
    end
  end

  def filter_time(spots_array, start_time_filter, end_time_filter)
    spots_array.select do |spot|
      spot.available_listings.any? do |listing|
        listing.is_available_between(start_time_filter, end_time_filter)
      end
    end
  end

  def sort(spots_array, sort_type)
    if sort_type && sort_type == "Price"
      spots_with_listings(spots_array).sort{|a,b| a.lowest_price_listing.price <=> b.lowest_price_listing.price}
    elsif sort_type && sort_type == "Closest Time"
      spots_with_listings(spots_array).sort{|a,b| a.closest_time_listing.beginning_time <=> b.closest_time_listing.beginning_time}
    elsif sort_type && sort_type == "Closest Spot"
      spots_with_listings(spots_array).sort{|a,b| a.distance_from_location(current_location[0], current_location[1]) <=> b.distance_from_location(current_location[0], current_location[1])}
    end
  end

  def parse_time(type_of_time)
    year = params["listing"]["#{type_of_time}(1i)"]
    month = params["listing"]["#{type_of_time}(2i)"]
    day = params["listing"]["#{type_of_time}(3i)"]
    hour = params["listing"]["#{type_of_time}(4i)"]
    minute = params["listing"]["#{type_of_time}(5i)"]
    DateTime.parse("#{year}/#{month}/#{day} #{hour}:#{minute}")
  end


end
