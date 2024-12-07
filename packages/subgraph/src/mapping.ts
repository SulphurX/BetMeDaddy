import { BigInt, Address } from "@graphprotocol/graph-ts";
import {
  YourContract,
  GreetingChange as GreetingChangeEvent,
  SendMessage as SendMessageEvent
} from "../generated/YourContract/YourContract";
import { GreetingChange, SendMessage } from "../generated/schema";

export function handleGreetingChange(event: GreetingChangeEvent): void {
  let entity = new GreetingChange(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.greetingSetter = event.params.greetingSetter
  entity.newGreeting = event.params.newGreeting
  entity.premium = event.params.premium
  entity.value = event.params.value

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleSendMessage(event: SendMessageEvent): void {
  let entity = new SendMessage(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity._from = event.params._from
  entity._to = event.params._to
  entity.message = event.params.message

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
