class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]

  def index
    @books = Book.all.order(updated_at: :desc)
  end

  def show
    @book = Book.includes(sections: :paragraphs).find(params[:id])
  end

  def new
    @book = Book.new
    @book.sections.build.paragraphs.build
  end

  def edit
    @book = Book.includes(sections: :paragraphs).find(params[:id])
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to edit_book_path(@book), notice: "Book was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      redirect_to edit_book_path(@book), notice: "Book was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path, notice: "Book was successfully deleted."
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :description, :published, :published_at)
  end
end
