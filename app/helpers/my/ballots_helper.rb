module My::BallotsHelper
  def ballots_list_item_path(user, ballot)
    if user.main_profile_id == ballot.profile_id
      my_ballot_path(ballot)
    else
      ballot_path(ballot)
    end
  end
end
