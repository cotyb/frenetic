open NetCore_Types
open Packet
open List

type get_packet_handler = 
    OpenFlow0x01.switchId -> Internal.port -> packet -> Internal.action
type get_count_handler = Int64.t -> Int64.t -> unit

type predicate =
  | And of predicate * predicate
  | Or of predicate * predicate
  | Not of predicate
  | All
  | NoPackets
  | Switch of OpenFlow0x01.switchId
  | InPort of portId
  | DlSrc of Int64.t
  | DlDst of Int64.t
  | DlVlan of int option (** 12-bits *)
  | DlTyp of int
  | SrcIP of Int32.t
  | DstIP of Int32.t
  | TcpSrcPort of int (** 16-bits, implicitly IP *)
  | TcpDstPort of int (** 16-bits, implicitly IP *)

type action =
  | Pass
  | Drop
  | To of int
  | ToAll
  | UpdateDlSrc of Int64.t * Int64.t
  | UpdateDlDst of Int64.t * Int64.t
  | UpdateDlVlan of int option * int option (** 12-bits *)
  | UpdateSrcIP of Int32.t * Int32.t
  | UpdateDstIP of Int32.t * Int32.t
  | UpdateSrcPort of int * int
  | UpdateDstPort of int * int
  | GetPacket of get_packet_handler
  | GetPacketCount of int * get_count_handler
  | GetByteCount of int * get_count_handler
      
type policy =
  | Empty
  | Act of action
  | Par of policy * policy (** parallel composition *)
  | Seq of policy * policy
  | Filter of predicate
  | Slice of predicate * policy * predicate
  | ITE of predicate * policy * policy

val par : policy list -> policy
  
val predicate_to_string : predicate -> string
  
val action_to_string : action -> string
  
val policy_to_string : policy -> string


val desugar : (unit -> int option) 
  -> (unit -> int) 
  -> ((int, (int * get_count_handler * bool)) Hashtbl.t)
  -> policy 
  -> Internal.pol
