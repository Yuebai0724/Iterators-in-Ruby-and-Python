(*
   Ocaml has lists built in but I redifined it for two reasons, one, fold
   and map are already defined for the builtin lists, and it shows you how
   to declare a relativly simple recursive data type.

   If you are familiar with lisp then you should be familar with how these
   lists are implemented. A list is either the empty list, nil in this case,
   or it is the head of a list and the rest of the list.

   The list [1] is equivalent to Cons (1, Nil).
   The list [1,2] is Cons (1, Cons (2, Nil)).
 *)
type 'a linkedlist = Nil
                   | Cons of 'a * 'a linkedlist;;
(*
   This tree is implemented as either a EmptyTree, in this case I called it a
   leaf, or as a branch, which contains a value of type a and a list of
   children, which are also trees.
 *)
type 'a tree = Leaf
             | Branch of 'a * 'a tree list;;

(*
   It isn't obvious why a queue can be implemented as a pair of lists, so I
   added a enqueue and dequeue functions. The secret is in the rebalance
   function. When an element is added it is put at the end of the inbox.
   When an item is removed from the queue, it is removed from the end of the
   outbox. The only time and item is moved from the inbox to the outbox is with
   the rebalancing function that is run when the outbox is empty. The beginning
   of the inbox is the oldest element in the queue when rebalancing is done,
   since the outbox is empty. Rebalancing moves elements from the inbox, to the
   outbox in reverse order. So the first element to be removed from the outbox
   on the next call to dequeue, is the oldest element in the queue. Hence, the
   FIFO invariant is preserved. This implementation of a queue is inspired by
   Chris Okasaki's PhD thesis, "Purely Functional Data Structures".
 *)
type 'a queue = Queue of 'a list * 'a list;;
let rec rebalance (Queue (inbox, outbox)) = match (inbox, outbox) with
  | ([], _) -> Queue (inbox, outbox)
  | (x::xs, ys) -> rebalance (Queue (xs, (x::ys)));;
let enqueue (Queue (inbox, outbox)) a = Queue(a :: inbox, outbox);;
let rec dequeue (Queue (inbox, outbox)) = match (inbox, outbox) with
  | ([], []) -> (Queue ([], []), None)
  | (_::_, []) -> dequeue (rebalance (Queue (inbox, outbox)))
  | (_, y::ys) -> (Queue (inbox, ys), Some y);;

let rec listMap f a = match a with
					| Nil -> Nil
					| Cons(x,b) -> Cons ((f x),(listMap f b));;

let rec listFold f a b= match b with
					| Nil -> a
					| Cons(x,c) -> listFold f (f a x) c;;

let rec treeMap f a = match a with
				   | Leaf -> Leaf
				   | Branch(x,b) -> Branch((f x),(List.map (treeMap f) b));;

let rec treeFold f a b = match b with
					  | Leaf -> a
					  | Branch(x,b) -> List.fold_left (treeFold f) (f a x) b

let queueMap f a = match a with
				| Queue(x,y) ->Queue ((List.map f x) , (List.map f y));;

let queueFold f a b = match b with
				   | Queue(x,y) -> f (List.fold_left f a x) (List.fold_left f a y);;
