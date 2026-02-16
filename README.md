# MycoWriter - Mushroom Article Creator

A Rails 8 application for creating and managing articles about mushrooms. Users can sign in, create their own articles with sections and paragraphs, and view articles created by other users.

## Features

- **User Authentication**: Secure sign-up and sign-in using Devise
- **Article Management**: Create, edit, and delete your own articles
- **Public Access**: All users can view all articles
- **Authorization**: Only article owners can edit or delete their articles
- **Sections & Paragraphs**: Organize articles with draggable sections and paragraphs
- **Clean UI**: Responsive design with Tailwind CSS and sidebar navigation

## Prerequisites

- Ruby 3.4.3 or higher
- Rails 8.0.4 or higher
- MySQL 5.6.4 or higher
- Node.js (for JavaScript runtime)
- Bundler

## Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd mycowriter
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Configure database**
   
   Copy `.env.example` to `.env` and set your MySQL credentials:
   ```
   MYSQL_USER=your_mysql_username
   MYSQL_PASSWORD=your_mysql_password
   DB_HOST=127.0.0.1
   ```

4. **Create and migrate database**
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   ```

5. **Start the server**
   ```bash
   bin/rails server
   ```

6. **Access the application**
   
   Open your browser to http://localhost:3000

## Usage

### For Users

1. **Sign Up**: Create an account with email, password, and display name
2. **Create Articles**: Add new articles with title and description
3. **Add Content**: Organize your articles with sections and paragraphs
4. **View All Articles**: Browse articles created by all users
5. **My Articles**: Quick access to your own articles

### Authorization Rules

- **Anyone** can view all articles
- **Logged-in users** can create new articles
- **Article owners** can edit and delete their own articles
- **Non-owners** cannot modify articles they didn't create

## Technology Stack

- **Framework**: Ruby on Rails 8.0.4
- **Ruby Version**: 3.4.3
- **Database**: MySQL
- **Authentication**: Devise
- **Authorization**: Pundit
- **Frontend**: Tailwind CSS, Hotwire (Turbo & Stimulus)
- **Testing**: Minitest

## Development

### Running Tests

```bash
bin/rails test
```

### Code Standards

This project follows the Rails 8 / Turbo standard pattern from the mrdbid project. See `CODING_STANDARDS.md` and `RAILS_8_TURBO_STANDARD_PATTERN.md` for details.

**Key Standards:**
- Never use `respond_to` blocks with `turbo_stream.action(:redirect)` 
- Always use simple `redirect_to` with `notice:` or `alert:` parameter
- All redirects use `status: :see_other` for non-GET requests

## License

This project is open source and available under the MIT License.

## Contact

For questions or issues, please open an issue on GitHub.

---

**Note**: This is a demonstration project. Always verify mushroom identifications with expert mycologists before consumption.
