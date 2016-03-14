class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
  	@orders = current_user.orders
  end

  def show
  	@order = current_user.orders.find(params[:id])
  end

  def new
    @order = Order.new

    params[:area][:seat_ids].pop
    session[:ids] = params[:area][:seat_ids]

    @seats = Seat.find(session[:ids])
    @order.seats << @seats

    @order.total_price
  end

  def create
    @order = Order.new(secure_params)
    @seats = Seat.find(session[:ids])
    @order.seats << @seats

    @order.save

    current_user.orders << @order

    Pingpp::Charge.create(
      :subject  => "ticket-booking",
      :body     => "Some things",
      :amount   => 100,
      :order_no => @order.id,
      :channel  => "alipay_pc_direct",
      :currency => "cny",
      :client_ip=> '127.0.0.1',
      :app => {'id' => "app_aH08OSaLmzP89Sin"},
      :extra => {'success_url' => '127.0.0.1' }
    )

  	redirect_to orders_path
  end

  def destroy
  	@order = current_user.orders.find(params[:id])
  	@order.destroy
  end

  def post_order
    Pingpp::Charge.create(
      :subject  => "ticket-booking",
      :body     => "Some things",
      :amount   => 100,
      :order_no => params[:order].id,
      :channel  => "upacp",
      :currency => "cny",
      :client_ip=> '127.0.0.1',
      :app => {'id' => "app_1Gqj58ynP0mHeX1q"}
    )
  end

  private

  def secure_params
  	params.require(:order).permit(:address, :phone, :name, :seat_ids => [])
  end
end