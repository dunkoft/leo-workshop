program armuttoplayici.aleo {
  mapping account:address => u64;
  record armut {
    owner: address;
    amount: u64;
  }
  transition mint_public(public reciever:address, public amount:u64){
    return then finalize(reciever,amount);
  }
  finalize mint_public(public reciever:address, amount:u64){
    let reciever_amount: u64 = Mapping::get_or_use(account,reciever, 0u64);
    Mapping::set(account, reciever, reciever_amount + amount);
    }
  transition mint_private(reciever:address, amount:u64) -> armut {
    return armut {
      owner:reciever,
      amount:amount
    };
  }
  transition transfer_public(public reciever:address, public amount:u64){
    return then finalize(self.caller,reciever,amount);

  }
  finalize transfer_public(public sender:address, public reciever:address, public amount:u64){
    let sender_amount:u64 = Mapping::get_or_use(account, sender, 0u64);
    Mapping::set(account, sender, sender_amount - amount);

    let reciever_amount:u64 = Mapping::get_or_use(account, reciever, 0u64);
    Mapping::set(account, reciever, reciever_amount + amount);
  }

  transition transfer_private(sender:armut, reciever:address, amount:u64) ->(armut,armut) {
    let difference:u64 = sender.amount - amount;

    let remaining: armut = armut{
      owner:sender.owner,
      amount:difference,
    };
    let transferred: armut = armut{
      owner:reciever,
      amount:amount,
    };
    return(remaining, transferred);
  }
  transition transfer_private_to_public(sender:armut, public reciever:address, public amount:u64) -> armut{
      let difference:u64 = sender.amount - amount;

      let remaining:armut = armut{
        owner:sender.owner,
        amount:difference,
      };
      return remaining then finalize(reciever, amount);
  }
  finalize transfer_private_to_public(public reciever:address, public amount:u64){
    let reciever_amount:u64 = Mapping::get_or_use(account, reciever, 0u64);
    Mapping::set(account, reciever, reciever_amount + amount);
  }
  transition transfer_public_to_private(public sender:address, public amount:u64) -> armut {
    let transferred:armut = armut{
      owner:sender,
      amount:amount,
    };
    return transferred then finalize(self.caller,amount);
  }
  finalize transfer_public_to_private(public sender:address, public amount:u64){
    let sender_amount:u64 = Mapping::get_or_use(account, sender, 0u64);
    Mapping::set(account, sender, sender_amount - amount);
  }
}
