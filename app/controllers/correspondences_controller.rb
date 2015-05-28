class CorrespondencesController < ApplicationController
  
  def index
    respond_to do |format|
      format.html
      format.json do
        if current_user
          if params[:correspondence_by] == "positions"
            correspondences = current_user.correspondences.includes(:users).where.not('users.id = ?', current_user.id).references(:users).includes(:positions).where.not('positions.user_id = ?', current_user.id).references(:positions).where("correspondence_type = 'positions'").as_json(include: [:positions], methods: [:user, :unreadable_count])
          elsif params[:correspondence_by] == "users"
            correspondences = current_user.correspondences.includes(:users).where.not('users.id = ?', current_user.id).references(:users).where("correspondence_type = 'users'").as_json(include: [:positions], methods: [:user])
          end
          render json: {
            correspondences: correspondences,
            unreadable_count: current_user.correspondences.new_messages_count(current_user)
          }
        else
          render json: []
        end
      end
    end
  end

  def start
    if current_user
      opponent = User.where(id: params[:id]).first

      if opponent
        if params[:msg].present?
          @correspondence = Correspondence.between_users(current_user, opponent)
          unless @correspondence
            @correspondence = Correspondence.create_between_users(current_user, opponent)
          end
          @correspondence.messages.create(sender_id: current_user.id, recipient_id: opponent.id, body: params[:msg], correspondence_id: @correspondence.id)
          render json: {id: @correspondence.id}
        else
          render json: {msg: I18n.t("message.notice.empty")}, status: 500
        end
      else
        render json: {msg: I18n.t("user.notice.not_found")}, status: 500
      end
    else
      render json: {msg: I18n.t("user.notice.not_auth")}, status: 500
    end
  end

  def with
    @correspondence = Correspondence.between_users(current_user, User.find(params[:user_id]))
    if @correspondence
      render json: {id: @correspondence}
    else
      render json: {}, status: 500
    end
  end

  def upload
    if current_user.correspondence_ids.include?(params[:correspondence_id].to_i) && $redisCorrespondencesFile
      document = Document.new
      document.document = params.permit(:document)[:document]
      if document.save
        $redisCorrespondencesFile.set(params[:correspondence_id], document.id)
        render json: {document: document, msg: I18n.t("file.upload.success")}
      else
        render json: {msg: I18n.t("file.upload.error")}, status: 500
      end
    else
      render json: {msg: I18n.t("file.upload.error")}, status: 500
    end
  end

  def delete_file
    if current_user.correspondence_ids.include?(params[:correspondence_id].to_i)
      $redisCorrespondencesFile.del(params[:correspondence_id])
      render json: {msg: I18n.t("file.remove.sucess")}
    else
      render json: {msg: I18n.t("file.remove.error")}, status: 500
    end
  end

  def find_correspondence
    position = current_user.positions.find(params[:position_id])
    offer = position.positions.find(params[:offer_id]) rescue position.offers.find(params[:offer_id])
    correspondence = Correspondence.between_positions(position.id, offer.id)
    render json: {id: correspondence.id}
  end

  def reset_count
    correspondence = current_user.correspondences.find(params[:correspondence_id])
    correspondence.read_all! current_user
    render json: {}
  end

  def show
    correspondence = current_user.correspondences.where(id: params[:id]).first
    if correspondence
      if params[:type]=='positions'
        position, offer = Position.position_and_offer(correspondence.position_ids, current_user.id)
      elsif params[:type]=='users'
        position, offer = nil, nil
      end

      if id = $redisCorrespondencesFile.get(params[:id])
        document = Document.where(id: id).first
      else
        document = nil
      end

      render json: {
        messages: correspondence.messages.includes(:sender, :document).last(25).as_json(Message::QUERY),
        correspondence: correspondence,
        position: position,
        offer: offer,
        document: document
      }
    else
      render json: {msg: I18n.t("correspondence.notice.not_found")}, status: 500
    end
  end

  def messages_page
    correspondence = current_user.correspondences.where("correspondences.id= ?", params[:id]).first
    position, offer = Position.position_and_offer(correspondence.position_ids, current_user.id)

    render json: {
      messages: correspondence.messages.offset(25*params[:page].to_i-25).last(25).as_json(Message::QUERY),
      page: params[:page]
    }
  end

  def new_message
    correspondence = current_user.correspondences.where(id: params[:id]).first
    if correspondence.present?
      @message = correspondence.messages.new(body: params[:body], sender_id: current_user.id, recipient_id: correspondence.users.where.not(id: current_user.id).first.id)
      
      if id = $redisCorrespondencesFile.get(params[:id])
        @message.document = Document.where(id: id).first
        $redisCorrespondencesFile.del(params[:id])
      end

      if @message.save
        @message = @message.as_json(Message::QUERY)
        render json: @message
      else
        render json: {msg: I18n.t("message.notice.sending_error")}, status: 500
      end
    else
      render json: {msg: I18n.t("correspondence.notice.not_found")}, status: 500
    end
  end

  def connection_id
    correspondences = current_user.correspondences.where(id: params[:id])
    if correspondence = correspondences.first
      user = User.where.not(id: current_user.id).first
      render json: {connection_id: user.connection_id}
    else
      render json: {msg: I18n.t("correspondence.notice.not_found")}
    end
  end

end
