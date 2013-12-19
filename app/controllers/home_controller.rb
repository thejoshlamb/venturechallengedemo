class HomeController < ApplicationController

  before_filter :ensure_logged_in

  def index
    redirect_to after_sign_in_path 
  end

  def admin
    @leagues = League.where("admin_id = '#{current_user.id}'")
  end

  def leaderboards
    # get all stores in current league
    if session[:shopify]
      redirect_to leagues_path unless current_store.league_id
      @league = League.find(current_store.league_id)
    elsif session[:linkedin]
      @admin_leagues = League.where("admin_id = #{current_user.id}")
      if params[:league]
        @league = League.find(params[:league])
      else  
        @league = League.find_by(admin_id: current_user.id)
      end
    end

    

    @stores = Store.where("league_id = #{@league.id}")
    @stores.each do |store|
      store.total_orders = Order.where("store_id = #{store.id}").sum(:subtotal_price)
    end
    @stores.sort!{ |a,b| a.total_orders <=> b.total_orders }.reverse!
    
    @orders = @league.orders
    @points = Point.all

    gon.numberofTeams = @stores.count

    league_countdown 

    initialize_pointschart unless @orders.count == 0 
  end

  def after_sign_in_path
     if session[:shopify]
       return leagues_path unless current_store.league_id
       return leaderboards_path
     elsif session[:linkedin]
       return adminpanel_path
     end
  end

  def league_countdown

    return @countdown = "Game Over!" if Time.now > @league.end_date

    t = @league.end_date - Time.now

    mm, ss = t.divmod(60)
    hh, mm = mm.divmod(60)
    dd, hh = hh.divmod(24)
    @countdown = "%d days, %d hours, %d minutes and %d seconds" % [dd, hh, mm, ss]
  
  end
  
  private

  def initialize_pointschart

    # array for colors
    gon.color = [] 

    #set number of time chunks
    timechunks = 10

    # setup time range 
    oldestordertime = @orders.maximum("created_at")
    timerange = oldestordertime - @league.start_date
    timeinterval = (timerange / timechunks) + 60
    chartlabelarray = [@league.start_date]
    
    #setup label array
    i = 1
    timechunks.times do
      chartlabelarray << (@league.start_date+(timeinterval * i))
      i += 1
    end

    #initialize array data
    gon.data = []

    opac = 1/(@stores.count).to_f

    @stores.each do |store|
      aggregatepoints = [0]
      i = 1
      (timechunks).times do 
        puts 
        timechunkpoints = store.points.select { |p| p.created_at.between?(chartlabelarray[0],chartlabelarray[i]) }
        aggregatepoints << timechunkpoints.map(&:value).sum
        i += 1
      end
      #generate random color and push into color array
      r = rand(255)
      g = rand(255)
      b = rand(255)
      linecolor = "rgba(#{r},#{g},#{b},1)"
      fillcolor = "rgba(#{r},#{g},#{b},#{opac})"
      gon.data << { 
        "name" => "#{User.find(store.user_id).name}", 
        "linecolor" => linecolor, 
        "fillcolor" => fillcolor,
        "points" => aggregatepoints, 
        "ident" => "store#{store.id}", 
        "totalpts" => Point.where("store_id = #{store.id}").sum(:value)
        }
    end

    #format label array and pass to .gon
    chartlabelarray.map!{|x| x.strftime("%m / %d") }
    gon.labels = chartlabelarray

  end

  def initialize_barchart 
    #initialize array data
    gon.bardata = []
    gon.bardata << gon.data.pluck("name")
  end

end
