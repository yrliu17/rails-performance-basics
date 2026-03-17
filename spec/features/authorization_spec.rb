require "rails_helper"

describe "Authorization" do
  it "does not allow a user to access another user's feed", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "appdev")

    visit "/"

    visit "/#{other_user.username}/feed"

    expect(page).to have_content("You're not authorized for that")
    expect(page).to have_current_path("/")
  end

  it "does not allow a user to access another user's discover", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "appdev")

    visit "/"

    visit "/#{other_user.username}/discover"

    expect(page).to have_content("You're not authorized for that")
    expect(page).to have_current_path("/")
  end

  it "does not show user option to delete another user's photo", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "appdev", private: false)
    photo = create_photo(owner: other_user, caption: "caption")

    visit "/photos/#{photo.id}"

    expect(page).to have_content(photo.caption)

    expect(page).not_to have_button("Delete")
  end

  it "does not show user option to edit another user's photo", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "appdev", private: false)
    photo = create_photo(owner: other_user, caption: "caption")

    visit "/photos/#{photo.id}"

    expect(page).to have_content(photo.caption)

    expect(page).not_to have_link("Edit")
  end

  it "does not show user option to delete another user's comment", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "appdev", private: false)
    photo = create_photo(owner: other_user, caption: "caption")
    comment = Comment.create(photo_id: photo.id, author_id: other_user.id, body: "comment")

    visit "/photos/#{photo.id}"

    expect(page).to have_content(comment.body)

    expect(page).not_to have_button("Delete")
  end

  it "does not show user option to edit another user's comment", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "appdev", private: false)
    photo = create_photo(owner: other_user, caption: "caption")
    comment = Comment.create(photo_id: photo.id, author_id: other_user.id, body: "comment")

    visit "/photos/#{photo.id}"

    expect(page).to have_content(comment.body)

    expect(page).not_to have_link("Edit")
  end

  it "does not show photos on a private user's profile page", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    private_user = User.create(username: "bob", email: "bob@example.com", password: "appdev")
    photo = create_photo(owner: private_user, caption: "caption")

    visit "/#{private_user.username}"

    expect(page).not_to have_content(photo.caption)
  end

  it "does not allow a user to access another user's pending page", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "appdev")

    visit "/"

    visit "/#{other_user.username}/pending"

    expect(page).to have_content("You're not authorized for that")
    expect(page).to have_current_path("/")
  end

  it "does not allow a user to view all photos", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    visit "/photos"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to view a private user's photo", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    private_user = User.create(username: "bob", email: "bob@example.com", password: "appdev")
    photo = create_photo(owner: private_user, caption: "secret caption")

    visit "/photos/#{photo.id}"

    expect(page).to have_content("You're not authorized for that")
    expect(page).not_to have_content("secret caption")
  end

  it "does not allow a user to view a like show page", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    photo = create_photo(owner: user, caption: "caption")
    like = Like.create(photo_id: photo.id, fan_id: user.id)

    visit "/likes/#{like.id}"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to view a like edit page", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    photo = create_photo(owner: user, caption: "caption")
    like = Like.create(photo_id: photo.id, fan_id: user.id)

    visit "/likes/#{like.id}/edit"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to view a comment show page", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    photo = create_photo(owner: user, caption: "caption")
    comment = Comment.create(photo_id: photo.id, author_id: user.id, body: "comment")

    visit "/comments/#{comment.id}"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to view all follow requests", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    visit "/follow_requests"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to view a follow request show page", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "appdev")
    follow_request = FollowRequest.create(sender_id: user.id, recipient_id: other_user.id, status: "pending")

    visit "/follow_requests/#{follow_request.id}"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to view a follow request edit page", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "appdev")
    follow_request = FollowRequest.create(sender_id: user.id, recipient_id: other_user.id, status: "pending")

    visit "/follow_requests/#{follow_request.id}/edit"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to visit the edit page for another user's photo", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "appdev", private: false)
    photo = create_photo(owner: other_user, caption: "caption")

    visit "/photos/#{photo.id}/edit"

    expect(page).to have_content("You're not authorized for that")
    expect(page).not_to have_css("form[action='/photos/#{photo.id}']")
  end

  it "does not allow a user to visit the edit page for another user's comment", points: 3 do
    user = User.create(username: "alice", email: "alice@example.com", password: "appdev")
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "appdev", private: false)
    photo = create_photo(owner: other_user, caption: "caption")
    comment = Comment.create(photo_id: photo.id, author_id: other_user.id, body: "comment")

    visit "/comments/#{comment.id}/edit"

    expect(page).to have_content("You're not authorized for that")
    expect(page).not_to have_css("form[action='/comments/#{comment.id}']")
  end
end

def sign_in(user)
  visit "/users/sign_in"

  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

def create_photo(owner:, caption: "caption")
  photo = Photo.new(caption: caption, owner_id: owner.id)
  photo.image.attach(io: File.open(Rails.root.join("spec/support/test_image.jpeg")), filename: "test_image.jpeg", content_type: "image/jpeg")
  photo.save!
  photo
end
