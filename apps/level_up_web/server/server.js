// server.js
const express = require('express');
const stripe = require('stripe')('YOUR_STRIPE_SECRET_KEY');

const app = express();
app.use(express.json());

app.post('/create-checkout-session', async (req, res) => {
  const { product_id, amount, success_url, cancel_url } = req.body;
  
  const session = await stripe.checkout.sessions.create({
    payment_method_types: ['card'],
    line_items: [{
      price_data: {
        currency: 'usd',
        product_data: {
          name: `LevelUp Coaching: ${product_id}`,
        },
        unit_amount: Math.round(amount * 100),
      },
      quantity: 1,
    }],
    mode: 'payment',
    success_url: success_url,
    cancel_url: cancel_url,
  });

  res.json({ sessionId: session.id });
});

app.listen(4242, () => console.log('Running on port 4242'));