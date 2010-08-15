class WeekdayController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  def index
    @batches = Batch.active
    @weekdays = Weekday.default
    @day = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    @days = ["0", "1", "2", "3", "4", "5", "6"]
  end

  def week
    @batch = nil
    @days = ["0", "1", "2", "3", "4", "5", "6"]
    @day = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    if params[:batch_id] == ''
      @weekdays = Weekday.default
    else
      @weekdays = Weekday.for_batch(params[:batch_id])
      @b  = Batch.find params[:batch_id]
    end
    render :update do |page|
      page.replace_html "weekdays", :partial => "weekdays"
    end
  end

  

  def create
    batch = params[:weekday][:batch_id]
    week = []
    if request.post?
      if params[:weekday][:batch_id].empty?
        @weekday =  Weekday.default
      else
        @weekday = Weekday.find_all_by_batch_id(batch)
      end
      @weekday.each do |x|
        x.delete
      end
      week = params[:weekdays]
      unless week.nil?
        week.each  do |w|
          Weekday.create(:batch_id => batch, :weekday=>w)
        end
      end
    end
    redirect_to :action => "index" 
  end
end
