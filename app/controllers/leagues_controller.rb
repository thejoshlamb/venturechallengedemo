class LeaguesController < ApplicationController
  
  def index
    @leagues = League.all
  end

  def show
     @league = League.find(params[:id])
  end

  def new
    @league = League.new
  end

  def create
    @league = League.new(league_params)
    @league.admin_id = current_user.id
    if @league.save
      redirect_to adminpanel_path
    else
      render :new
    end
  end

  def update
     @league = League.find(params[:id])

    if @league.update_attributes(league_params)
      redirect_to league_path(@league)
    else
      render :edit
    end
  end

  def assign_league
    if params[:pin].to_i == League.find(params[:league_id]).pin
    store = Store.find_by_user_id(current_user.id)
    store.league_id = params[:league_id]
    store.save
    redirect_to root_path
    else
    redirect_to leagues_path, notice: "Invalid PIN"
    end  
  end
  

  def edit
    @league = League.find(params[:id])
  end

  def destroy
       @league = League.find(params[:id])
    @league.destroy
    redirect_to adminpanel_path
  end

  private

  def league_params
    params.require(:league).permit(:name, :school, :start_date, :end_date, :pin)
  end


end
