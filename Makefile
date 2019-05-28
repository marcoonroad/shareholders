build:
	@ dune build

dev-deps:
	@ opam install ocamlformat odoc merlin bisect_ppx utop ocp-indent --yes

deps:
	@ opam install . --deps-only

utop: build
	@ dune utop lib

clear: build
	@ dune clean

lint-format: build
	@ dune build @fmt

format: build
	@ dune build @fmt --auto-promote || \
		echo "\nText was rewritten to comply to standards/formats.\n"

test: build lint-format
	@ dune build @test/spec/runtest --no-buffer -f -j 1

run-examples: build lint-format
	@ dune build @examples/runtest --no-buffer -f -j 1

docs: build
	@ dune build @doc

install: build
	@ dune install

uninstall:
	@ dune uninstall

coverage: clear
	@ BISECT_ENABLE=yes make build
	@ BISECT_ENABLE=yes make test
	@ bisect-ppx-report \
	  -title shareholders \
		-I _build/default/ \
		-tab-size 2 \
		-html coverage/ \
		`find . -name 'bisect*.out'`
	@ bisect-ppx-report \
		-I _build/default/ \
		-text - \
		`find . -name 'bisect*.out'`
