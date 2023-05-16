#!/bin/bash
echo Finding useless parentheses in grammars...
for i in `find . -name desc.xml | grep -v Generated\*`
do
  d=`dirname $i`
  echo $d
  pushd $d > /dev/null 2>&1
  trparse -l -t ANTLRv4 *.g4 2> /dev/null > o.pt
  status=$?
  if [ "$status" != "0" ]
  then
    echo Crash
  else
    if [ -f o.pt ] && [ -s o.pt ]
    then
      cat o.pt | trxgrep '
        (: Find all blocks... :)
        //block[
                (: except not one of these ... :)
                not(./parent::ebnf/blockSuffix and ./altList/OR) and
                not(./parent::ebnf/blockSuffix and count(./altList/alternative/element) > 1) and
                not(./altList/OR and ../../following-sibling::element) and
                not(./altList/OR and ../../preceding-sibling::element) and
		not(./parent::labeledElement/(ASSIGN or PLUS_ASSIGN))
        ]' | trcaret
      cat o.pt | trxgrep '
        (: Find all blocks... :)
        //lexerBlock[
                (: except not one of these ... :)
                not(./parent::lexerElement/ebnfSuffix and ./lexerAltList/OR) and
                not(./parent::lexerElement/ebnfSuffix and count(./lexerAltList/lexerAlt/lexerElements/lexerElement) > 1) and
                not(./lexerAltList/OR and ../following-sibling::lexerElement) and
                not(./lexerAltList/OR and ../preceding-sibling::lexerElement) and
                not(./parent::lexerElement/ebnfSuffix and ./lexerAltList/lexerAlt/lexerElements/lexerElement/lexerAtom/characterRange) and
                not(count(./lexerAltList/lexerAlt) > 1 and ../../../lexerCommands) and
		not(./parent::labeledLexerElement/(ASSIGN or PLUS_ASSIGN))
        ]' | trcaret
      cat o.pt | trxgrep '
        (: Find all blockSets... :)
        //blockSet[
                (: except not one of these ... :)
                not(./OR)
        ]' | trcaret
      rm -f o.pt
    fi
  fi

  popd > /dev/null 2>&1
done