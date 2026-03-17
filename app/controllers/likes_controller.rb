class LikesController < ApplicationController
  before_action :set_like, only: %i[ destroy ]

  # GET /photos/:photo_id/likes
  def index
    @photo = Photo.find(params[:photo_id])
    @likes = @photo.likes
  end

  # POST /likes or /likes.json
  def create
    @like = Like.new(like_params)
    @like.fan = current_user

    respond_to do |format|
      if @like.save
        format.html { redirect_back fallback_location: @like.photo, notice: "Like was successfully created." }
        format.json { render :show, status: :created, location: @like }
      else
        format.html { redirect_back fallback_location: @like.photo, alert: "Failed to like photo." }
        format.json { render json: @like.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /likes/1 or /likes/1.json
  def destroy
    @like.destroy!

    respond_to do |format|
      format.html { redirect_back fallback_location: @like.photo, notice: "Like was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_like
      @like = Like.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def like_params
      params.expect(like: [:fan_id, :photo_id])
    end
end
