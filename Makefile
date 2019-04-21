dev-deps:
	opam install ocamlformat odoc --yes

utop:
	dune utop lib

clear:
	dune clean

build:
	dune build

lint-format:
	dune build @fmt

format:
	dune build @fmt --auto-promote

test: build lint-format
	dune build @test/spec/runtest --no-buffer -f -j 1

run-examples: build lint-format
	dune build @examples/runtest --no-buffer -f -j 1

docs: build
	dune build @doc

install: build
	dune install

uninstall:
	dune uninstall

coverage: clear
	BISECT_ENABLE=yes make build
	BISECT_ENABLE=yes make test
	bisect-ppx-report \
	  -title shareholders \
		-I _build/default/ \
		-tab-size 2 \
		-html coverage/ \
		`find . -name 'bisect*.out'`
	bisect-ppx-report \
		-I _build/default/ \
		-text - \
		`find . -name 'bisect*.out'`
