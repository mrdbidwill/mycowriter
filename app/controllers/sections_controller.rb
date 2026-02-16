class SectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_article
  before_action :authorize_article
  before_action :set_section, only: [ :update, :destroy, :move_up, :move_down ]

  def create
    @section = @article.sections.build(section_params)

    if @section.save
      redirect_to edit_article_path(@article), notice: "Section was successfully created.", status: :see_other
    else
      redirect_to edit_article_path(@article), alert: "Error creating section: #{@section.errors.full_messages.join(', ')}", status: :see_other
    end
  end

  def update
    if @section.update(section_params)
      render json: {
        id: @section.id,
        title: @section.title
      }
    else
      render json: { errors: @section.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @section.destroy
    head :no_content
  end

  def move_up
    @section.move_higher
    render json: { position: @section.position }
  end

  def move_down
    @section.move_lower
    render json: { position: @section.position }
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def authorize_article
    authorize @article, :update?
  end

  def set_section
    @section = @article.sections.find(params[:id])
  end

  def section_params
    params.require(:section).permit(:title)
  end
end
