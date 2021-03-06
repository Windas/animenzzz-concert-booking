class AreasController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:create]

  def index
  	@recital = Recital.includes(:areas).find(params[:recital_id])
  	# @areas = @recital.areas
  	@seats = []
  	@recital.areas.each do |area|
  	  area.seats.each do |seat|
  	  	if seat.sold then
          seat_data = {}
          seat_data[:sold] = seat.sold 
          seat_data[:klass] = seat.area.klass 
          seat_data[:row] = seat.locate_x 
          seat_data[:num] = seat.locate_y
          @seats << seat_data
        end
  	  end
  	end

  	respond_to do |format|  
      format.html
      format.json { render :json => @seats }
    end  
  end

  # def show
  # 	@recital = Recital.find params[:recital_id]
  # 	@area = @recital.areas.find(params[:id])
  # end

  def create
    cd = params[:data]
    cd.each do |floor| 
      floor.each do |areas|
      	areas.each do |area|
      	  next if area[:type] != 'seat'
          a = Area.where(:klass => area[:area]).first
          next if a.name != 'C区' and a.name != 'D区' and a.name != 'K区'
          next if Area.joins(:seats).where(klass: area[:area], seats: {locate_x: area[:row], locate_y: area[:num]}).size != 0
      	  seat = Seat.create(locate_x: area[:row], locate_y: area[:num])
      	  price = Price.where(:price => area[:price]).first
      	  price.seats << seat
      	  price.save
      	  a.seats << seat 
      	  a.save
      	end 
      end
    end 
  end
end
