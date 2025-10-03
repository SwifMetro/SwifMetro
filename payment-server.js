/**
 * SwifMetro Payment Server
 * Handles Stripe payments and license key generation
 */

require('dotenv').config();
const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const app = express();

// Enable CORS for localhost:8080
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', 'http://localhost:8080');
    res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    if (req.method === 'OPTIONS') {
        return res.sendStatus(200);
    }
    next();
});

app.use(express.json());
app.use(express.static('.'));

const PORT = 3000;
const PRICE = 2999; // $29.99 in cents

// Store license keys (in production, use a database)
const LICENSE_DB = path.join(__dirname, 'licenses.json');
if (!fs.existsSync(LICENSE_DB)) {
    fs.writeFileSync(LICENSE_DB, JSON.stringify([], null, 2));
}

// Generate license key: SWIF-XXXX-XXXX-XXXX
function generateLicenseKey() {
    const part1 = crypto.randomBytes(2).toString('hex').toUpperCase();
    const part2 = crypto.randomBytes(2).toString('hex').toUpperCase();
    const part3 = crypto.randomBytes(2).toString('hex').toUpperCase();
    return `SWIF-${part1}-${part2}-${part3}`;
}

// Save license to database
function saveLicense(email, licenseKey, customerId) {
    const licenses = JSON.parse(fs.readFileSync(LICENSE_DB));
    licenses.push({
        email,
        licenseKey,
        customerId,
        createdAt: new Date().toISOString(),
        status: 'active'
    });
    fs.writeFileSync(LICENSE_DB, JSON.stringify(licenses, null, 2));
}

// Create checkout session
app.post('/create-checkout-session', async (req, res) => {
    try {
        const { email } = req.body;
        
        const session = await stripe.checkout.sessions.create({
            mode: 'subscription',
            customer_email: email,
            line_items: [
                {
                    price_data: {
                        currency: 'usd',
                        product_data: {
                            name: 'SwifMetro Pro',
                            description: 'Wireless iOS logging - 7-day free trial',
                        },
                        unit_amount: PRICE,
                        recurring: {
                            interval: 'month',
                        },
                    },
                    quantity: 1,
                },
            ],
            subscription_data: {
                trial_period_days: 7,
            },
            success_url: `http://localhost:${PORT}/success.html?session_id={CHECKOUT_SESSION_ID}`,
            cancel_url: `http://localhost:${PORT}/swiftmetro.html`,
        });

        res.json({ url: session.url });
    } catch (error) {
        console.error('Error creating checkout session:', error);
        res.status(500).json({ error: error.message });
    }
});

// Get session details and generate license key
app.get('/session-details', async (req, res) => {
    try {
        const { session_id } = req.query;
        const session = await stripe.checkout.sessions.retrieve(session_id);
        
        if (session.payment_status === 'paid' || session.status === 'complete') {
            // Generate license key
            const licenseKey = generateLicenseKey();
            const email = session.customer_email;
            
            // Save to database
            saveLicense(email, licenseKey, session.customer);
            
            res.json({
                success: true,
                email,
                licenseKey,
                trialEnd: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
            });
        } else {
            res.json({ success: false });
        }
    } catch (error) {
        console.error('Error retrieving session:', error);
        res.status(500).json({ error: error.message });
    }
});

// Webhook endpoint for Stripe events
app.post('/webhook', express.raw({type: 'application/json'}), async (req, res) => {
    const sig = req.headers['stripe-signature'];
    
    try {
        const event = stripe.webhooks.constructEvent(
            req.body,
            sig,
            process.env.STRIPE_WEBHOOK_SECRET
        );
        
        console.log('📬 Webhook received:', event.type);
        
        switch (event.type) {
            case 'checkout.session.completed':
                const session = event.data.object;
                console.log('✅ Payment successful:', session.customer_email);
                break;
                
            case 'customer.subscription.deleted':
                const subscription = event.data.object;
                console.log('❌ Subscription cancelled:', subscription.customer);
                // Mark license as inactive
                break;
        }
        
        res.json({ received: true });
    } catch (err) {
        console.error('Webhook error:', err.message);
        res.status(400).send(`Webhook Error: ${err.message}`);
    }
});

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', stripe: 'connected' });
});

app.listen(PORT, () => {
    console.log('');
    console.log('💳 SWIFMETRO PAYMENT SERVER');
    console.log('='.repeat(50));
    console.log(`🚀 Server running on http://localhost:${PORT}`);
    console.log(`💰 Price: $${(PRICE / 100).toFixed(2)}/month`);
    console.log(`🎁 Trial: ${process.env.TRIAL_DAYS} days`);
    console.log('');
    console.log('📝 Test payment with Stripe test cards:');
    console.log('   Card: 4242 4242 4242 4242');
    console.log('   Exp: Any future date');
    console.log('   CVC: Any 3 digits');
    console.log('='.repeat(50));
    console.log('✅ Payment server is now listening!');
    console.log('');
});
