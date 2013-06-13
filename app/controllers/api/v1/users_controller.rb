module Api
  module V1
    class UsersController < ApiBaseController
      respond_to :json

      def index
        respond_with User.all
      end

      def show
        respond_with User.find(params[:id])
      end

      def create
        user = User.new(params[:user])
        if user.save
          respond_with(user, :location => api_v1_user_path(user))
        else
          respond_with(user)
        end
      end

      def update
        user = User.find(params[:id])
        user.update_attributes(params[:user])
        respond_with(user)
      end

      def destroy
        user = User.find(params[:id])
        respond_with(user)
      end
    end
  end
end