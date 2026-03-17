desc "Fill the database tables with some sample data"
task sample_data: :environment do
  starting = Time.now

  # Make Faker output deterministic across runs
  Faker::Config.random = Random.new(42)

  # Clear only user-uploaded assets in appdev_2/ — stable seed images live
  # outside this folder and are intentionally left untouched.
  begin
    Cloudinary::Api.delete_resources_by_prefix("appdev_2/")
  rescue Cloudinary::Api::NotFound
    # Folder didn't exist yet, no-op
  end

  # Skip the default-avatar callback — we attach avatars manually below
  User.skip_callback(:create, :before, :set_default_avatar)

  # Reset all PK sequences to 1
  ActiveRecord::Base.connection.tables.each do |table|
    next if ["schema_migrations", "ar_internal_metadata"].include?(table)
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE")
  end

  FollowRequest.destroy_all
  Comment.destroy_all
  Like.destroy_all
  Photo.destroy_all
  User.destroy_all

  people = [
    { first_name: "Alice", last_name: "Smith" },
    { first_name: "Bob", last_name: "Smith" },
    { first_name: "Carol", last_name: "Smith" },
    { first_name: "Dave", last_name: "Smith" },
    { first_name: "Eve", last_name: "Smith" },
    { first_name: "Frank", last_name: "Wilson" },
    { first_name: "Grace", last_name: "Brown" },
    { first_name: "Henry", last_name: "Davis" },
    { first_name: "Ivy", last_name: "Miller" },
    { first_name: "Jack", last_name: "Anderson" }
  ]

  avatar_images = [
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179672/10_tr3zoy.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179671/9_ozfgiu.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179671/8_pwngi1.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179671/7_pugev9.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179671/6_mobbi4.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179670/5_g6rxlz.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179670/4_qpszok.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179670/3_dymuoe.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179670/2_fb9rdr.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179670/1_njmhvj.jpg"
  ]

  photo_images = [
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179692/10_op0tpz.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179691/9_iyhady.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179691/8_d5opde.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179691/7_rb5fmu.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179690/6_zvmuwq.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179690/5_ogrjwc.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179690/4_ow4t9b.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179689/3_fx6akk.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179689/2_kl1hpb.jpg",
    "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1743179689/1_rnywum.jpg"
  ]

  counter = 0
  people.each do |person|
    username = person.fetch(:first_name).downcase

    user = User.new(
      email: "#{username}@example.com",
      password: "appdev",
      username: username.downcase,
      display_name: "#{person[:first_name]} #{person[:last_name]}",
      bio: "#{person[:first_name]} loves #{Faker::Hobby.activity.downcase} and #{Faker::Hobby.activity.downcase}.",
      website: Faker::Internet.url,
      private: username.in?(%w[bob carol eve ivy])
    )

    # Skip validations so we can attach the avatar separately
    user.save(validate: false)

    attach_stable_cloudinary_url(user.avatar_image, avatar_images[counter])

    if username == "alice"
      attach_stable_cloudinary_url(user.profile_banner,
        "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1773249329/banner_bpzka2.jpg")
    end

    counter += 1
  end

  users = User.all

  users.each do |first_user|
    users.each do |second_user|
      next if first_user == second_user

      if first_user.username.in?(%w[alice bob carol dave])
        first_user.sent_follow_requests.create(
          recipient: second_user,
          status: "accepted"
        )
      end

      if second_user.username.in?(%w[eve frank grace])
        second_user.sent_follow_requests.create(
          recipient: first_user,
          status: "pending"
        )
      end
    end
  end

  photo_counter = 0
  users.each do |user|
    3.times do |i|
      photo = user.own_photos.new(
        caption: Faker::GreekPhilosophers.quote,
        pinned: user.username == "alice" && i == 0
      )

      # Skip validations so we can attach the image separately
      photo.save(validate: false)

      attach_stable_cloudinary_url(photo.image, photo_images[photo_counter % photo_images.length])
      photo_counter += 1

      user.followers.each do |follower|
        if follower.username.in?(%w[alice bob eve frank])
          photo.fans << follower
        end

        if follower.username.in?(%w[carol dave grace])
          photo.comments.create(
            body: Faker::GreekPhilosophers.quote,
            author: follower
          )
        end
      end
    end
  end

  ending = Time.now
  p "It took #{(ending - starting).to_i} seconds to create sample data."
  p "There are now #{User.count} users."
  p "There are now #{FollowRequest.count} follow requests."
  p "There are now #{Photo.count} photos."
  p "There are now #{Like.count} likes."
  p "There are now #{Comment.count} comments."
end

# Attaches a stable Cloudinary URL by extracting its public_id and creating
# an ActiveStorage::Blob record directly — no upload, no network request.
# The Cloudinary AS adapter uses blob.key as the public_id when serving URLs.
def attach_stable_cloudinary_url(attachment, url)
  # e.g. ".../upload/v1743179672/10_tr3zoy.jpg" → "10_tr3zoy"
  public_id = url.split("/upload/").last
                 .sub(/\Av\d+\//, "")   # strip version segment
                 .sub(/\.\w+\z/, "")    # strip extension
  ext = File.extname(url).delete_prefix(".")
  blob = ActiveStorage::Blob.find_or_create_by!(key: public_id) do |b|
    b.filename     = File.basename(url)
    b.content_type = "image/#{ext}"
    b.byte_size    = 0
    b.checksum     = SecureRandom.hex
    b.service_name = "cloudinary_sample_data"
  end
  attachment.attach(blob)
end
