class ParagraphsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_section
  before_action :authorize_book
  before_action :set_paragraph, only: [ :update, :destroy, :move_up, :move_down ]

  def create
    @paragraph = @section.paragraphs.build(paragraph_params)

    if @paragraph.save
      redirect_to edit_article_path(@section.article), notice: "Paragraph was successfully created.", status: :see_other
    else
      redirect_to edit_article_path(@section.article), alert: "Error creating paragraph: #{@paragraph.errors.full_messages.join(', ')}", status: :see_other
    end
  end

  def update
    if @paragraph.update(paragraph_params)
      render json: {
        id: @paragraph.id,
        content: @paragraph.content
      }
    else
      render json: { errors: @paragraph.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @paragraph.destroy
    head :no_content
  end

  def move_up
    @paragraph.move_higher
    render json: { position: @paragraph.position }
  end

  def move_down
    @paragraph.move_lower
    render json: { position: @paragraph.position }
  end

  private

  def set_section
    @section = Section.find(params[:section_id])
  end

  def authorize_book
    authorize @section.article, :update?
  end

  def set_paragraph
    @paragraph = @section.paragraphs.find(params[:id])
  end

  def paragraph_params
    params.require(:paragraph).permit(:content)
  end
end
