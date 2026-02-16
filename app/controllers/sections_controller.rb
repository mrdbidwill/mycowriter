class SectionsController < ApplicationController
  before_action :set_book
  before_action :set_section, only: [:update, :destroy, :move_up, :move_down]

  def create
    @section = @book.sections.build(section_params)
    @section.position = @book.sections.maximum(:position).to_i + 1

    if @section.save
      redirect_to edit_book_path(@book), notice: "Section was successfully created."
    else
      redirect_to edit_book_path(@book), alert: "Error creating section: #{@section.errors.full_messages.join(', ')}"
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

  def set_book
    @book = Book.find(params[:book_id])
  end

  def set_section
    @section = @book.sections.find(params[:id])
  end

  def section_params
    params.require(:section).permit(:title)
  end
end
