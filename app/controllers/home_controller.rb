class HomeController < ApplicationController

  before_filter :ensure_logged_in
  
  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login"
  end
  
  def index
    if session[:shopify]
      if curent_user
      #if so, show stuff
      #if not, display leagues to join
    elsif session[:user_id]
      redirect_to adminpanel_path
    end
  end

  def admin
    @leagues = League.where("admin_id = '#{current_user.id}'")
  end
  

  private

  def refresh_store_data # probably not necessary
    @stores = Store.all
  
    @stores.each do |s|
    session = ShopifyAPI::Session.new(s.myshopify_domain, s.access_token)
    ShopifyAPI::Base.activate_session(session)


      @orders  = ShopifyAPI::Order.find(:all, :params => {:order => "created_at DESC" }) 

      @customers  = ShopifyAPI::Customer.find(:all, :params => {:order => "created_at DESC" }) 

      s.order_count = @orders.count
      s.customer_count = @customers.count
      ordersum = 0
      @orders.each do |order|
        ordersum += order.total_price.to_f
      end

      s.total_orders = ordersum
      s.save! 

    end
  end


end
