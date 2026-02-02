# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# Create sample users
users = []

users << User.find_or_create_by!(email: "demo@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.first_name = "Demo"
  u.last_name = "User"
  u.phone = "9876543210"
  u.country_code = "+91"
end

users << User.find_or_create_by!(email: "rahul@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.first_name = "Rahul"
  u.last_name = "Sharma"
  u.phone = "9876543211"
  u.country_code = "+91"
end

users << User.find_or_create_by!(email: "priya@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.first_name = "Priya"
  u.last_name = "Patel"
  u.phone = "9876543212"
  u.country_code = "+91"
end

users << User.find_or_create_by!(email: "amit@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.first_name = "Amit"
  u.last_name = "Kumar"
  u.phone = "9876543213"
  u.country_code = "+91"
end

puts "Created/Found #{users.count} users"

# Clear existing trips for clean seeding
Trip.destroy_all
puts "Cleared existing trips"

# Sample trips covering all types (no title - creator name will be shown)
trips_data = [
  {
    user: users[0], # Demo User
    destination: "Goa",
    description: "Join us for an amazing beach vacation in Goa! We'll explore the famous beaches, try water sports, and enjoy the nightlife. Perfect for adventure seekers and beach lovers.",
    start_date: Date.today + 15.days,
    end_date: Date.today + 20.days,
    expires_at: Date.today + 12.days,
    image_url: "https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800",
    max_people: 6,
    current_people: 2,
    sponsored: true,
    has_car: true,
    open_for_joining: true
  },
  {
    user: users[1], # Rahul Sharma
    destination: "Manali",
    description: "Experience the magic of snow-capped mountains in Manali. Skiing, snowboarding, and cozy bonfires await. Looking for fellow snow enthusiasts!",
    start_date: Date.today + 7.days,
    end_date: Date.today + 12.days,
    expires_at: Date.today + 2.days, # Expiring soon!
    image_url: "https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=800",
    max_people: 4,
    current_people: 1,
    sponsored: false,
    has_car: true,
    open_for_joining: true
  },
  {
    user: users[2], # Priya Patel
    destination: "Jaipur",
    description: "Explore the rich heritage of Rajasthan. Visit majestic forts, colorful markets, and experience royal hospitality. A cultural journey like no other.",
    start_date: Date.today + 30.days,
    end_date: Date.today + 37.days,
    expires_at: Date.today + 25.days,
    image_url: "https://images.unsplash.com/photo-1477587458883-47145ed94245?w=800",
    max_people: 8,
    current_people: 3,
    sponsored: true,
    has_car: false,
    open_for_joining: true
  },
  {
    user: users[3], # Amit Kumar
    destination: "Kerala",
    description: "Cruise through the serene backwaters of Kerala on a traditional houseboat. Enjoy authentic cuisine and peaceful surroundings. Limited spots available!",
    start_date: Date.today + 10.days,
    end_date: Date.today + 14.days,
    expires_at: Date.today + 1.day, # Expiring very soon!
    image_url: "https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=800",
    max_people: 4,
    current_people: 2,
    sponsored: false,
    has_car: false,
    open_for_joining: true
  },
  {
    user: users[1], # Rahul Sharma
    destination: "Ladakh",
    description: "The ultimate road trip! Ride through the highest motorable roads in the world. Experience breathtaking landscapes and test your limits.",
    start_date: Date.today + 45.days,
    end_date: Date.today + 55.days,
    expires_at: Date.today + 40.days,
    image_url: "https://images.unsplash.com/photo-1626686007697-5c56e8ceb7c8?w=800",
    max_people: 5,
    current_people: 1,
    sponsored: false,
    has_car: false,
    open_for_joining: true
  },
  {
    user: users[2], # Priya Patel
    destination: "Rishikesh",
    description: "Find your inner peace at the yoga capital of the world. Daily yoga sessions, meditation, and river rafting. Transform your mind and body.",
    start_date: Date.today + 20.days,
    end_date: Date.today + 25.days,
    expires_at: Date.today + 15.days,
    image_url: "https://images.unsplash.com/photo-1545389336-cf090694435e?w=800",
    max_people: 10,
    current_people: 4,
    sponsored: true,
    has_car: true,
    open_for_joining: true
  },
  {
    user: users[0], # Demo User
    destination: "Udaipur",
    description: "Romantic trip to the City of Lakes. Already have my travel buddy, sharing for visibility. Not open for joining but happy to share tips!",
    start_date: Date.today + 25.days,
    end_date: Date.today + 28.days,
    expires_at: Date.today + 20.days,
    image_url: "https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800",
    max_people: 2,
    current_people: 2,
    sponsored: false,
    has_car: true,
    open_for_joining: false # Not open for joining - full trip
  },
  {
    user: users[3], # Amit Kumar
    destination: "Meghalaya",
    description: "Trek to the famous living root bridges of Meghalaya. Explore caves, waterfalls, and pristine villages. An offbeat adventure awaits!",
    start_date: Date.today + 5.days,
    end_date: Date.today + 10.days,
    expires_at: Date.today + 2.days, # Expiring soon!
    image_url: "https://images.unsplash.com/photo-1614087435928-12e20fcb1b6b?w=800",
    max_people: 6,
    current_people: 3,
    sponsored: false,
    has_car: false,
    open_for_joining: true
  }
]

trips_data.each do |trip_data|
  user = trip_data.delete(:user)
  trip = user.trips.create!(trip_data)
  puts "Created trip to #{trip.destination} by #{user.full_name}"
end

puts "\n✅ Seeding complete!"
puts "Created #{Trip.count} trips"
puts "\nTrip breakdown:"
puts "  - Sponsored: #{Trip.sponsored.count}"
puts "  - With car: #{Trip.with_car.count}"
puts "  - Open for joining: #{Trip.open_for_joining.count}"
puts "  - Expiring soon: #{Trip.expiring_soon.count}"
puts "\nPopular destinations:"
Trip.popular_destinations(5).each do |dest|
  puts "  - #{dest[:destination]}: #{dest[:trip_count]} trips"
end
