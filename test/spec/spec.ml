(* Environment Variables:
   - ALCOTEST_QUICK_TESTS
   - ALCOTEST_SHOW_ERRORS
   - ALCOTEST_VERBOSE
*)

;;
Alcotest.run
  "shareholders specification"
  [ ("secret sharing", Sharing.suite)
  ; ("secret recovering", Recovering.suite)
  ; ("secret verification", Verification.suite)
  ]
