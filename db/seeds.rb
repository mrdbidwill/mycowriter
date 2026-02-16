# Clear existing data (optional - comment out if you want to keep existing data)
# Article.destroy_all
# User.destroy_all

# Create a test user
user = User.find_or_create_by!(email: 'test@example.com') do |u|
  u.display_name = 'Test User'
  u.password = 'password123'
  u.password_confirmation = 'password123'
end

puts "Created user: #{user.display_name} (#{user.email})"

# Create a test article for the user
if user.articles.empty?
  article = user.articles.create!(
    title: "Introduction to Mushroom Identification",
    description: "A comprehensive guide to identifying common mushrooms",
    published: true,
    published_at: Time.current
  )

  # Add a section with paragraphs
  section1 = article.sections.create!(
    title: "Getting Started",
    position: 1
  )

  section1.paragraphs.create!(
    content: "Welcome to the world of mushroom identification! This guide will help you learn the basics of identifying common mushrooms in your area.",
    position: 1
  )

  section1.paragraphs.create!(
    content: "Before you begin, it's important to remember that mushroom identification can be dangerous if done incorrectly. Always consult with experts and use multiple sources.",
    position: 2
  )

  # Add another section
  section2 = article.sections.create!(
    title: "Safety First",
    position: 2
  )

  section2.paragraphs.create!(
    content: "Never consume a mushroom unless you are 100% certain of its identification. Many poisonous mushrooms look similar to edible ones.",
    position: 1
  )

  puts "Created article: #{article.title} with #{article.sections.count} sections"
end

puts "\nSeeding complete!"
puts "You can sign in with: test@example.com / password123"
