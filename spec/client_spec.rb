require 'spec_helper'

describe Venice::Client do
  let(:receipt_data) { "asdfzxcvjklqwer" }
  let(:client) { subject }

  describe "#verify!" do
    context "no shared_secret" do
      before do
        client.shared_secret = nil
        allow(Venice::Receipt).to receive(:new)
      end

      it "should only include the receipt_data" do
        expect_any_instance_of(Net::HTTP).to receive(:request) do |post|
          expect(post.body).to eql({'receipt-data' => receipt_data}.to_json)
          post
        end
        client.verify! receipt_data
      end
    end

    context "with a shared secret" do
      let(:secret) { "shhhhhh" }

      before do
        client.shared_secret = secret
        allow(Venice::Receipt).to receive(:new)
      end

      it "should include the secret in the post" do
        expect_any_instance_of(Net::HTTP).to receive(:request) do |post|
          expect(post.body).to eql({'receipt-data' => receipt_data, 'password' => secret}.to_json)
          post
        end
        client.verify! receipt_data
      end
    end

    context "with a latest receipt info attribute" do
      before do
        allow(client).to receive(:json_response_from_verifying_data).and_return(response)
      end

      let(:response) do
        {
          'status' => 0,
          'receipt' => {},
          'latest_receipt' => "<encoded string>",
          'latest_receipt_info' =>  {
            "original_purchase_date_pst" => "2012-12-30 09:39:24 America/Los_Angeles",
            "unique_identifier" => "0000b01147b8",
            "original_transaction_id" => "1000000061051565",
            "expires_date" => "1365114731000",
            "transaction_id" => "1000000070104252",
            "quantity" => "1",
            "product_id" => "com.ficklebits.nsscreencast.monthly_sub",
            "original_purchase_date_ms" => "1356889164000",
            "bid" => "com.ficklebits.nsscreencast",
            "web_order_line_item_id" => "1000000026812043",
            "bvrs" => "0.1",
            "expires_date_formatted" => "2013-04-04 22:32:11 Etc/GMT",
            "purchase_date" => "2013-04-04 22:27:11 Etc/GMT",
            "purchase_date_ms" => "1365114431000",
            "expires_date_formatted_pst" => "2013-04-04 15:32:11 America/Los_Angeles",
            "purchase_date_pst" => "2013-04-04 15:27:11 America/Los_Angeles",
            "original_purchase_date" => "2012-12-30 17:39:24 Etc/GMT",
            "item_id" => "590265423"
          }
        }
      end

      it "should create a latest receipt" do
        receipt = client.verify! 'asdf'
        expect(receipt.latest_receipt).not_to be_nil
      end
    end

  end
end
