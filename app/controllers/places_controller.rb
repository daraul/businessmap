class PlacesController < ApplicationController
    before_action :set_place, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!, only: [:edit, :update, :destroy, :create, :new]
    before_action :authorize_user, only: [:edit, :update, :destroy]
    
    # GET /places
    # GET /places.json
    def index
        @places = Place.search(params[:query]).filter(params).paginate(:page => params[:page], :per_page => 10)

        respond_to do |format|
            format.html do 
                js :places => @places
            end 

            format.js
        end 
    end
    
    def your_places 
        @places = Place.where(user_id: current_user.id) 
    end 
    
    # GET /places/1
    # GET /places/1.json
    def show
        respond_to do |format| 
            format.html do 
                js :place => @place 
            end 

            format.js 
        end 
    end
    
    # GET /places/new
    def new
        @place = Place.new
        
        @pictures = @place.pictures

        js :place => @place 
    end
    
    # GET /places/1/edit
    def edit
        @pictures = @place.pictures

        js :place => @place 
    end
    
    # POST /places
    # POST /places.json
    def create
        @place = Place.new(place_params)
        
        @place.user = current_user
        
        respond_to do |format|
            if @place.save
                format.html { redirect_to @place, notice: 'Place was successfully created.' }
                
                format.json { render :show, status: :created, location: @place }
            else
                format.html { redirect_to new_place_path, alert: @place.errors.messages.first[1][0] }
                
                format.json { render json: @place.errors, status: :unprocessable_entity }
            end 
        end
    end
    
    # PATCH/PUT /places/1
    # PATCH/PUT /places/1.json
    def update
        respond_to do |format|
            if @place.update(place_params)
                format.html { redirect_to @place, notice: 'Place was successfully updated.' }
                
                format.json { render :show, status: :created, location: @place }
            else
                format.html { redirect_to edit_place_path(@place), alert: @place.errors.messages.first[1][0] }
                
                format.json { render json: @place.errors, status: :unprocessable_entity }
            end 
        end
    end
    
    # DELETE /places/1
    # DELETE /places/1.json
    def destroy
        @place.destroy
        
        respond_to do |format|
            format.html { redirect_to places_url, notice: 'Place was successfully destroyed.' }
            
            format.json { head :no_content }
        end
    end
    
    private
    # Use callbacks to share common setup or constraints between actions.
    def set_place
        @place = Place.find(params[:id])
    end
    
    def authorize_user 
        if @place.user != current_user
            flash.alert = "You're not authorized to do that!"
            
            redirect_to root_path
        end 
    end 
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def place_params
        params.require(:place).permit(:description, :address, :latitude, :longitude, :rooms, :bathrooms, :for, :price, :contact, pictures_attributes: [:image]) 
    end
end