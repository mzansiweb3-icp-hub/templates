import Int "mo:base/Int";
import TrieMap "mo:base/TrieMap";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
actor {

  type User = {
    name : Text;
    email : Text;
    age : Nat;
    accessLevel : AccessLevel;
    timestamp : Int;
  };

  type AccessLevel = {
    #ADMIN;
    #USER;
    #GUEST;
  };

  var users = TrieMap.TrieMap<Text, User>(Text.equal, Text.hash);
  stable var usersEntries: [(Text, User)] = [];

  system func preupgrade() {
    usersEntries := Iter.toArray(users.entries());
  };

  system func postupgrade() {
    users := TrieMap.fromEntries(usersEntries.vals(), Text.equal, Text.hash);
  };

  public shared func createUser(args : User) : async () {
    users.put(args.email, args);
  };

  public shared query func getUser(email : Text) : async Result.Result<User, Text> {
    switch (users.get(email)) {
      case (null) {
        return #err("User not found");
      };
      case (?user) {
        return #ok(user);
      };
    };
  };

  public shared func updateUser(args : User) : async () {
    users.put(args.email, args);
  };

  public shared func deleteUser(email : Text) : async () {
    users.delete(email);
  };

  public shared query func getAllUsers() : async [User] {
    Iter.toArray(users.vals());
  };

  public shared query func getUserAccessLevel(email : Text) : async Result.Result<Text, Text> {
    switch (users.get(email)) {
      case (null) {
        return #err("User not found");
      };
      case (?user) {
        switch (user.accessLevel) {
          case (#ADMIN) {
            return #ok("You are an ADMIN");
          };
          case (#USER) {
            return #ok("You are just a USER");
          };
          case (#GUEST) {
            return #ok("You are a GUEST");
          };
        };
      };
    };
  };
};
