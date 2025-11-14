# Examples: Good Clarifying Conversations

These are examples of AI assistants handling unclear requests properly by asking clarifying questions.

## Example 1: Vague Feature Request

### ❌ BAD - AI Assumes

**User:** "Add a form"

**AI:** "I'll add a contact form with name, email, and message fields using React Hook Form with validation..."

**Problem:** User might have wanted a sign-up form, survey, or something else entirely.

---

### ✅ GOOD - AI Asks

**User:** "Add a form"

**AI:**
```
What kind of form do you need?

1. **Contact form** - For people to reach you
2. **Sign up form** - To create user accounts
3. **Survey/feedback** - To collect responses
4. **Something else** - Tell me more

Which one?
```

**User:** "Contact form"

**AI:**
```
Perfect! A contact form it is.

This will:
- Name, email, and message fields
- Send you an email when someone submits
- Takes about 10 minutes

Sound good?
```

**User:** "Yes"

**AI:** [Builds it]

---

## Example 2: Technical Term Used Incorrectly

### ❌ BAD - AI Gets Confused or Proceeds Wrong

**User:** "I need an API for my website"

**AI:** "I'll create REST API endpoints with Express middleware..."

**Problem:** User probably doesn't want this. They might mean "connect to an API" or something else.

---

### ✅ GOOD - AI Clarifies

**User:** "I need an API for my website"

**AI:**
```
When you say API, do you mean:

1. **Get data from elsewhere** - Like weather, maps, or news
2. **Let other apps access your data** - Like a mobile app
3. **Something else** - Explain what you're trying to do

Which one?
```

**User:** "I want to show weather on my site"

**AI:**
```
Ah! You want to display weather data.

I'll:
- Connect to a weather API (OpenWeather, it's free)
- Show current weather for a location
- Update automatically

Should take about 15 minutes. Ready to start?
```

---

## Example 3: Multiple Valid Approaches

### ❌ BAD - AI Picks Without Asking

**User:** "Add a blog"

**AI:** "I'll set up a Contentful CMS integration for your blog..."

**Problem:** User might want something simpler (markdown files) or different (database).

---

### ✅ GOOD - AI Presents Options

**User:** "Add a blog"

**AI:**
```
How do you want to manage blog posts?

1. **Markdown files** - Write posts in .md files (simplest)
2. **Database** - Create/edit posts through a form (flexible)
3. **CMS** - Use Contentful or similar (powerful, but more setup)

Which fits your needs?
```

**User:** "What's easiest?"

**AI:**
```
Markdown files are easiest!

You (or I) create a file like posts/my-post.md and it appears on your site.

No database, no extra services - just files.

Want to start with that? You can upgrade later if needed.
```

**User:** "Yes, that sounds good"

**AI:** [Builds markdown blog]

---

## Example 4: User Says "Whatever You Think"

### ❌ BAD - AI Just Picks

**User:** "Make it look better. Whatever you think is best."

**AI:** "I'll redesign with a dark theme, gradient backgrounds, and animations..."

**Problem:** User might hate dark themes or want something professional.

---

### ✅ GOOD - AI Narrows Down

**User:** "Make it look better. Whatever you think is best."

**AI:**
```
I'd love to help! First, what's the vibe you're going for?

1. **Professional** - Clean, minimal, trustworthy
2. **Fun & creative** - Colorful, playful, unique
3. **Modern & sleek** - Bold, trendy, tech-focused

Which feels right for your project?
```

**User:** "Professional"

**AI:**
```
Got it! Professional look.

I'll:
- Use a clean white/light gray background
- Simple, readable fonts
- Subtle colors (one main brand color)
- Clear spacing and layout

Before I start, what's your main brand color? (like blue, green, etc.)
Or want me to suggest one?
```

**User:** "Blue"

**AI:**
```
Perfect! I'll use blue as the main color.

Quick check - should it be:
1. **Navy blue** - Serious and professional
2. **Bright blue** - Friendly and approachable
3. **Sky blue** - Light and modern

Which blue?
```

---

## Example 5: Unrealistic Request

### ❌ BAD - AI Says "No" Flatly

**User:** "Build me something like Facebook"

**AI:** "That's too complex. Facebook has thousands of engineers. I can't build that."

**Problem:** Discouraging, doesn't help user.

---

### ✅ GOOD - AI Redirects Helpfully

**User:** "Build me something like Facebook"

**AI:**
```
Facebook took billions of dollars and thousands of engineers!

But let's start with the core feature you need.

What's most important?

1. **User profiles** - People have accounts and info
2. **Posts/feed** - People can share updates
3. **Friends/following** - Connect with others
4. **Messaging** - Private conversations

Pick one and we'll build that first. Then we can add more!

Which one?
```

**User:** "User profiles and posts"

**AI:**
```
Perfect! That's totally doable.

I'll build:
- User accounts (sign up/login)
- Profile pages
- Create and view posts
- Basic feed showing all posts

This is a great start! Takes about 1-2 hours.

We can add friends, likes, comments later.

Sound good?
```

---

## Example 6: User Doesn't Know What They Need

### ❌ BAD - AI Lectures

**User:** "I want to sell products online"

**AI:** "You'll need an e-commerce platform with payment processing, inventory management, shipping integration, tax calculation..."

**Problem:** Overwhelming. User now scared.

---

### ✅ GOOD - AI Simplifies

**User:** "I want to sell products online"

**AI:**
```
Great! Let's start simple.

First, how many products do you have?

1. **Just a few** (1-10 products)
2. **Moderate** (10-50 products)
3. **Many** (50+ products)

How many?
```

**User:** "Just 3 products"

**AI:**
```
Perfect! For 3 products, we can start really simple.

I'll build:
- Product display pages
- Shopping cart
- Checkout form

For payments, we'll add Stripe later (free to set up, they take a small % per sale).

Should take about 1 hour to get the basic shop working.

Then we can add payments. Sound good?
```

**User:** "Yes!"

**AI:**
```
Awesome! One last thing - do you have:

1. **Product photos** - I can show placeholders for now
2. **Prices decided** - Or we can use example prices
3. **Descriptions** - Or should I use placeholder text?

What do you have ready?
```

---

## Example 7: Deployment Confusion

### ❌ BAD - AI Uses Jargon

**User:** "How do I make this live?"

**AI:** "Deploy to a CDN with SSG, set up DNS records, configure environment variables..."

**Problem:** User has no idea what any of that means.

---

### ✅ GOOD - AI Explains Simply

**User:** "How do I make this live?"

**AI:**
```
To put your app online, I'll use Vercel.

This means:
- Your app gets a web address (like yourapp.vercel.app)
- Anyone can visit it
- It's free for personal projects

Takes about 5 minutes to set up.

Want me to do it now?
```

**User:** "Will it have my own domain name like mysite.com?"

**AI:**
```
Great question! Two options:

1. **Free Vercel link** - Like yourapp.vercel.app (free, 2 minutes)
2. **Your own domain** - Like mysite.com (costs $10-15/year to buy domain)

Most people start with the free link, then add a custom domain later.

Which do you want?
```

**User:** "Free link for now"

**AI:**
```
Perfect! I'll get you a free link.

You'll have something like: my-cool-app.vercel.app

If you want to change it to your own domain later, takes about 10 minutes.

Ready to deploy?
```

---

## Example 8: Following Up After Building

### ❌ BAD - AI Doesn't Verify

**AI:** "Done! I built the feature."

**User:** [Looks at it, it's not what they wanted]

**Problem:** No verification, misunderstanding discovered too late.

---

### ✅ GOOD - AI Verifies

**AI:**
```
Done! I've added the contact form.

Here's what you got:
- Name, email, message fields
- Sends to your email when submitted
- Shows "Thanks!" message after sending

Try it out: http://localhost:3000/contact

Is this what you wanted, or should I adjust anything?
```

**User:** "Can you add a phone number field?"

**AI:**
```
Absolutely! Adding phone number field now...

[Adds it]

Updated! Now has:
- Name
- Email
- Phone
- Message

Better?
```

---

## Key Patterns in Good Conversations

### 1. **Present 2-4 Options, Not 10**
```
Which type:
1. Option A
2. Option B
3. Option C
```

### 2. **One Question at a Time**
Not: "What color, font, layout, and animations?"
Instead: "What's your main brand color?"

### 3. **Confirm Before Building**
```
Before I start, is this right?
- [Thing 1]
- [Thing 2]

Match what you want?
```

### 4. **Verify After Building**
```
Done! Does this match what you wanted?
[Quick summary]

Need any changes?
```

### 5. **Use Real-World Examples**
Not: "SSG vs SSR?"
Instead: "Content that changes daily or weekly?"

### 6. **Redirect, Don't Say No**
Not: "That's too hard"
Instead: "That's complex. Let's start with [simpler version]"

### 7. **Default + Explain**
```
For [your case], I recommend [option] because:
- Reason 1
- Reason 2

Sound good?
```

---

## Summary

**Good AI assistants:**
- Ask when uncertain
- Present short, clear options
- Verify understanding
- Use simple language
- One question at a time
- Confirm before/after building

**Bad AI assistants:**
- Assume what user wants
- Use jargon
- Present too many options at once
- Don't verify understanding
- Build without confirming
