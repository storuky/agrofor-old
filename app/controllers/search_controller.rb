class SearchController < ApplicationController
  def index

  end

  def map
  end

  def list
  end

  def all
    if params[:marker]=="true"
      positions = Position.where(status: 'opened', deal_with_id: nil).markers
      render json: positions
    else
      page = params[:page] || 1
      favorite_ids = current_user.favorite_ids rescue []
      result = {
        positions: Position.where(status: 'opened', deal_with_id: nil).where.not(id: favorite_ids).offset(25*page.to_i-25).last(25),
        page: params[:page]
      }

      if page == 1
        result[:favorites] = Position.where(id: favorite_ids)
      end

      render json: result
    end
  end

  def suitable
    positions = Position.find_suitable Position.where(id: params[:position_ids])
    if params[:marker]
      render json: positions.markers
    else
      page = params[:page] || 1
      favorite_ids = current_user.favorite_ids rescue []
      result = {
        positions: positions.where.not(id: favorite_ids).offset(25*page.to_i-25).last(25),
        page: params[:page]
      }

      if page == 1
        result[:favorites] = positions.where(id: favorite_ids)
      end

      render json: result
    end
  end

  def by_params
    with_options = params[:position][:option_id].length>0 rescue false 
    if with_options || params[:position][:query].present?
      positions = Position.find_by_params(params[:position], params[:marker])
      if params[:marker]
        render json: positions.markers
      else
        page = params[:page] || 1
        favorite_ids = current_user.favorite_ids rescue []
        result = {
          positions: positions.where.not(id: favorite_ids).offset(25*page.to_i-25).last(25),
          page: params[:page]
        }

        if page == 1
          result[:favorites] = positions.where(id: favorite_ids)
        end

        render json: result

      end
    else
      render json: {errors: {category: I18n.t("search.dictionary.category_not_checked")} }, status: 500
    end
  end
end
