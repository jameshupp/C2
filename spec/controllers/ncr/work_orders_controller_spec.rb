describe Ncr::WorkOrdersController do
  include ProposalSpecHelper

  describe "#create" do
    it "sends an email to the first approver" do
      params = {
        ncr_work_order: {
          amount: "111.22",
          expense_type: "BA80",
          vendor: "Vendor",
          not_to_exceed: "0",
          building_number: Ncr::BUILDING_NUMBERS[0],
          emergency: "0",
          rwa_number: "A1234567",
          ncr_organization_id: create(:ncr_organization).code_and_name,
          code: "Work Order",
          project_title: "Title",
          description: "Desc",
          approving_official_id: approving_official.id
        }
      }

      login_as(create(:user, client_slug: "ncr"))

      post :create, params
      ncr = Ncr::WorkOrder.order(:id).last

      expect(ncr.code).to eq 'Work Order'
      expect(ncr.approvers.first).to eq approving_official
      expect(email_recipients).to eq([approving_official.email_address, ncr.requester.email_address].sort)
    end
  end

  describe '#edit' do
    let (:work_order) { create(:ncr_work_order, :with_approvers) }
    let (:requester) { work_order.proposal.requester }
    before do
      login_as(requester)
    end

    it 'does not display a message when the proposal is not fully approved' do
      get :edit, {id: work_order.id}
      expect(flash[:warning]).not_to be_present
    end

    it 'displays a warning message when editing a fully-approved proposal' do
      fully_complete(work_order.proposal)
      get :edit, {id: work_order.id}
      expect(flash[:warning]).to be_present
    end

    it "does not explode if editing an emergency" do
      work_order = create(
        :ncr_work_order,
        :is_emergency,
        requester: requester
      )

      get :edit, { id: work_order.id }
    end
  end

  describe '#update' do
    let (:work_order) { create(:ncr_work_order) }
    let (:requester) { work_order.proposal.requester }
    before do
      login_as(requester)
    end

    it 'does not modify the work order when there is a bad edit' do
      post :update, {
        id: work_order.id,
        ncr_work_order: {
          expense_type: 'BA61',
          amount: 999999,
          approving_official_id: approving_official.id
        }
      }
      expect(flash[:success]).not_to be_present
      expect(flash[:error]).to be_present
      work_order.reload
      expect(work_order.amount).not_to eq(999999)
    end

    it 'respects FY start date for setting default max amount' do
      Timecop.freeze(Time.zone.parse('2015-10-02')) do

        # must reload class for time travel to affect validations
        ['EXPENSE_TYPES', 'BUILDING_NUMBERS', 'WorkOrder'].each do |const|
          Ncr.send(:remove_const, const)
        end
        load 'app/models/ncr/work_order.rb'

        post :update, {
          id: work_order.id,
          ncr_work_order: {
            expense_type: 'BA61',
            amount: 99999,
            approving_official_id: approving_official.id
          }
        }
        expect(flash[:success]).not_to be_present
        expect(flash[:error]).to eq(["Amount must be less than or equal to $3,500.00"])
      end
    end

    it "allows the project title to be edited" do
      new_title = "new title"
      post :update, {
        id: work_order.id,
        ncr_work_order: {
         project_title: new_title,
        }
      }

      work_order.reload
      expect(work_order.project_title).to eq(new_title)
    end

    it "allows the approver to be edited" do
      work_order.setup_approvals_and_observers

      post :update, {
        id: work_order.id,
        ncr_work_order: {
         expense_type: 'BA61',
         approving_official_id: approving_official.id
        }
      }
      work_order.reload
      expect(work_order.approvers.first).to eq(approving_official)
    end

    it "does not modify the approver if already approved" do
      work_order.setup_approvals_and_observers
      work_order.reload.individual_steps.first.complete!

      post :update, {
        id: work_order.id,
        ncr_work_order: {
         expense_type: 'BA61',
         approving_official_id: approving_official.id
        }
      }
      work_order.reload
      expect(work_order.approvers).not_to include(approving_official)
    end

    it "will not modify emergency status on non-emergencies" do
      work_order.setup_approvals_and_observers
      expect(work_order.steps.empty?).to be false
      expect(work_order.observers.empty?).to be true

      post :update, {
        id: work_order.id,
        ncr_work_order: {
         expense_type: 'BA61',
         emergency: '1',
         approving_official_id: work_order.approvers.first.id
        }
      }

      work_order.reload
      expect(work_order.emergency).to be false
      expect(work_order.steps.empty?).to be false
      expect(work_order.observers.empty?).to be true
    end

    it "will not modify emergency status on emergencies" do
      work_order = create(:ncr_work_order, :is_emergency, requester: requester)
      expect(work_order.steps.empty?).to be true
      expect(work_order.observers.empty?).to be false

      post :update, {
        id: work_order.id,
        ncr_work_order: {
         expense_type: "BA61",
         building_number: "BillDing",
         emergency: "0",
         approving_official_id: work_order.observers.first.id
        }
      }

      work_order.reload
      expect(work_order.emergency).to be true
      expect(work_order.building_number).to eq "BillDing"
      expect(work_order.steps.empty?).to be true
      expect(work_order.observers.empty?).to be false
    end
  end

  private

  def approving_official
    @_approving_official ||= create(:user, client_slug: "ncr")
  end
end
