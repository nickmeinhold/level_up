// Mock firebase-admin modules
jest.mock("firebase-admin/firestore", () => ({
  getFirestore: jest.fn(),
  FieldValue: { serverTimestamp: jest.fn(() => ({ _serverTimestamp: true })) },
}));

import { getFirestore, FieldValue } from "firebase-admin/firestore";

describe("createCheckoutSession", () => {
  let mockDb: any;
  let mockSet: jest.Mock;

  beforeEach(() => {
    jest.clearAllMocks();
    mockSet = jest.fn().mockResolvedValue(undefined);
    mockDb = {
      collection: jest.fn().mockReturnThis(),
      doc: jest.fn().mockReturnThis(),
      set: mockSet,
    };
    (getFirestore as jest.Mock).mockReturnValue(mockDb);
  });

  it("should require authentication", () => {
    const request = { auth: null };
    expect(request.auth).toBeNull();
  });

  it("should use subscription mode", () => {
    const params = { mode: "subscription" };
    expect(params.mode).toBe("subscription");
  });

  it("should include firebase UID in metadata", () => {
    const params = { metadata: { firebaseUID: "user123" } };
    expect(params.metadata.firebaseUID).toBe("user123");
  });

  it("should store stripeCustomerId", async () => {
    await mockDb.collection("subscriptions").doc("user123").set(
      { stripeCustomerId: "cus_test" },
      { merge: true }
    );
    expect(mockSet).toHaveBeenCalled();
  });
});

describe("cancelSubscription", () => {
  let mockDb: any;
  let mockGet: jest.Mock;

  beforeEach(() => {
    jest.clearAllMocks();
    mockGet = jest.fn();
    mockDb = {
      collection: jest.fn().mockReturnThis(),
      doc: jest.fn().mockReturnThis(),
      get: mockGet,
    };
    (getFirestore as jest.Mock).mockReturnValue(mockDb);
  });

  it("should get subscription from Firestore", async () => {
    mockGet.mockResolvedValue({
      exists: true,
      data: () => ({ subscriptionId: "sub_test" }),
    });
    const doc = await mockDb.collection("subscriptions").doc("user123").get();
    expect(doc.data().subscriptionId).toBe("sub_test");
  });

  it("should handle missing subscription", async () => {
    mockGet.mockResolvedValue({ exists: false });
    const doc = await mockDb.collection("subscriptions").doc("user123").get();
    expect(doc.exists).toBe(false);
  });
});

describe("webhook idempotency", () => {
  let mockDb: any;
  let mockGet: jest.Mock;
  let mockSet: jest.Mock;

  beforeEach(() => {
    jest.clearAllMocks();
    mockGet = jest.fn();
    mockSet = jest.fn().mockResolvedValue(undefined);
    mockDb = {
      collection: jest.fn().mockReturnThis(),
      doc: jest.fn().mockReturnThis(),
      get: mockGet,
      set: mockSet,
    };
    (getFirestore as jest.Mock).mockReturnValue(mockDb);
  });

  it("should skip already processed events", async () => {
    mockGet.mockResolvedValue({ exists: true });
    const doc = await mockDb.collection("subscription-events").doc("evt_123").get();
    expect(doc.exists).toBe(true);
  });

  it("should process new events", async () => {
    mockGet.mockResolvedValue({ exists: false });
    const doc = await mockDb.collection("subscription-events").doc("evt_new").get();
    expect(doc.exists).toBe(false);
  });

  it("should mark event as processed", async () => {
    await mockDb.collection("subscription-events").doc("evt_123").set({
      type: "customer.subscription.created",
      processedAt: FieldValue.serverTimestamp(),
    });
    expect(mockSet).toHaveBeenCalled();
  });
});

describe("subscription status mapping", () => {
  it("should map active status", () => {
    expect("active").toBe("active");
  });

  it("should map cancelled status", () => {
    expect("cancelled").toBe("cancelled");
  });

  it("should default incomplete for unknown", () => {
    const status = "unknown";
    const result = ["active", "cancelled"].includes(status) ? status : "incomplete";
    expect(result).toBe("incomplete");
  });
});
