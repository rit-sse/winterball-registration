class GuestsController < ApplicationController
  # GET /guests
  # GET /guests.json
  def index
    @guests = Guest.all(:order => :ticketnumber)
    @success = flash[:success]
    @name = flash[:name]
    @ticket = flash[:ticket]
    @dir = flash[:dir] || "in"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @guests }
    end
  end

  # GET /guests/1
  # GET /guests/1.json
  def show
    @guest = Guest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @guest }
    end
  end

  # GET/PUT /guests/checkin/1
  # GET/PUT /guests/checkin/1.json
  def checkin
    @guest = Guest.find_by_ticketnumber(params[:ticket])
    
    @saved = false
    if @guest != nil then
      # They have a ticket, mark them arrived
      @guest.arrived = true
      @saved = @guest.save
    end
    
    flash[:success] = @saved
    flash[:ticket] = params[:ticket]
    flash[:dir] = "in"
    
    respond_to do |format|
      if @saved then
        flash[:name] =  @guest.name
        format.html { redirect_to :action => "index" }
        format.json { render head :ok }
      else
        if @guest != nil then
          format.html { redirect_to @guest }
          format.json { render json: @guest.errors, status: :unprocessable_entity }
        else
          format.html { redirect_to :action => "new", :ticketnumber => params[:ticket] }
          format.json { render json: @guest }
        end
      end
    end
  end

  # GET/PUT /guests/checkout/1
  # GET/PUT /guests/checkout/1.json
  def checkout
    if params[:ticket].nil? then
      @guests = Guest.all
      @guests.each do |guest|
        guest.arrived = false
        guest.save
      end
      respond_to do |format|
        format.html { redirect_to guests_path }
        format.json { render head :ok }
      end
    else
      @guest = Guest.find_by_ticketnumber(params[:ticket])
      
      @saved = false
      if @guest != nil then
        # They have a ticket, mark them left
        @guest.arrived = false
        @saved = @guest.save
      end

      flash[:success] = @saved
      flash[:ticket] = params[:ticket]
      flash[:dir] = "out"

      respond_to do |format|
        if @saved then
          flash[:name] =  @guest.name
          format.html { redirect_to :action => "index" }
          format.json { render head :ok }
        else
          if @guest != nil then
            format.html { redirect_to @guest }
            format.json { render json: @guest.errors, status: :unprocessable_entity }
          else
            format.html { redirect_to :action => "new", :ticketnumber => params[:ticket] }
            format.json { render json: @guest }
          end
        end
      end
    end
  end

  # GET /guests/mass
  def massform
    @failures = flash[:failures] || Array.new
  end

  # POST /guests/mass/add
  # POST /guests/mass/add.json
  def massadd
    csv = params[:csv]
    avail = !csv.nil?
    
    failures = Array.new
    
    if avail then
      csv.each_line do |line|
        parts = line.split(',')
        if parts.length == 4 then
          if parts.at(0).length > 0 and parts.at(2).length > 0 then
            first = Guest.new(:name => parts.at(0), :ticketnumber => parts.at(2).to_i, :arrived => false, :wonprize => false)
            if !first.save then
              failures << first.name + ": " + first.errors.reduce("") { |memo, obj| memo + " " + obj.to_s }
            end
          end
          if parts.at(1).length > 0 and parts.at(3).length > 0 then
            second = Guest.new(:name => parts.at(1), :ticketnumber => parts.at(3).to_i, :arrived => false, :wonprize => false)
            if !second.save then
              failures << second.name + ": " + second.errors.reduce("") { |memo, obj| memo + " " + obj.to_s }
            end
          end
        else
          failures << line
        end
      end
    end
    
    flash[:failures] = failures
    
    respond_to do |format|
      if failures.length != 0 then
        format.html { redirect_to :action => "massform" }
        format.json { render json: failures, status: :unprocessable_entity }
      else
        format.html { redirect_to :action => "massform" }
        format.json { head :ok }
      end
    end
    
  end

  # GET /guests/raffle
  def raffle
    @guests = Guest.where(:wonprize => false, :arrived => true)
    if @guests.count > 0 then
      @guest = @guests.find(:first, :offset => rand(@guests.count))
      render :action => "show", :id => @guest.id
    else
      render :rafflemissing
    end
  end

  # GET /guests/new
  # GET /guests/new.json
  def new
    @guest = Guest.new
    if params[:ticketnumber] != nil then
      @guest.ticketnumber = params[:ticketnumber]
    end
    if params[:arrived] != nil or (!@guest.ticketnumber.nil? and @guest.ticketnumber > 0) then
      @guest.arrived = true
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @guest }
    end
  end

  # GET /guests/1/edit
  def edit
    @guest = Guest.find(params[:id])
  end

  # POST /guests
  # POST /guests.json
  def create
    @guest = Guest.new(params[:guest])

    respond_to do |format|
      if @guest.save
        #format.html { redirect_to @guest, notice: 'Guest was successfully created.' }
        format.html { redirect_to new_guest_path, notice: 'Guest was successfully created.' }
        format.json { render json: @guest, status: :created, location: @guest }
      else
        format.html { render action: "new" }
        format.json { render json: @guest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /guests/1
  # PUT /guests/1.json
  def update
    @guest = Guest.find(params[:id])

    respond_to do |format|
      if @guest.update_attributes(params[:guest])
        format.html { redirect_to @guest, notice: 'Guest was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @guest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /guests/1
  # DELETE /guests/1.json
  def destroy
    @guest = Guest.find(params[:id])
    @guest.destroy

    respond_to do |format|
      format.html { redirect_to guests_url }
      format.json { head :ok }
    end
  end
end
