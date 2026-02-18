class ArticlesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_article, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_article, only: [ :edit, :update, :destroy ]

  def index
    @articles = if user_signed_in? && params[:my_articles]
               current_user.articles.includes(:user, :sections).order(updated_at: :desc)
    else
               Article.includes(:user, :sections).order(updated_at: :desc)
    end
  end

  def show
    @article = Article.includes(sections: :paragraphs).find(params[:id])
    authorize @article
  end

  def new
    @article = current_user.articles.build
    authorize @article
    section = @article.sections.build
    section.paragraphs.build
  end

  def edit
    @article = Article.includes(sections: :paragraphs).find(params[:id])
  end

  def create
    @article = current_user.articles.build(article_params)
    authorize @article

    if @article.save
      redirect_to edit_article_path(@article), notice: "Article was successfully created.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @article.update(article_params)
      flash[:notice] = "✓ Article saved successfully"
      redirect_to edit_article_path(@article), status: :see_other
    else
      flash.now[:alert] = @article.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  rescue Rack::QueryParser::ParamsTooDeepError, RangeError => e
    flash.now[:alert] = "Content is too large to save. Please reduce the size."
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @article.destroy
    redirect_to articles_path, notice: "Article was successfully deleted.", status: :see_other
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def authorize_article
    authorize @article
  end

  def article_params
    params.require(:article).permit(:title, :description, :body, :published, :published_at)
  end
end
