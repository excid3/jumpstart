module Admin
  class UsersController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = User.
    #     page(params[:page]).
    #     per(10)
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   User.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    def resource_params
        attrs = User.column_names.map &:to_sym
        attrs.delete(:id)
        attrs.delete(:created_at)
        attrs.delete(:updated_at)
        attrs << :password
        params.require(:user).permit(attrs)
    end

  end
end