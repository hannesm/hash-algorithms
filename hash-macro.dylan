module: hash-algorithms

define macro hash-definer
  { define hash ?:name (?digest-size:expression; ?block-size:expression) } =>
    {
      define C-subtype "<" ## ?name ## "-context>" (<C-void*>) end;

      define C-function "init-" ## ?name
        result context :: "<" ## ?name ## "-context>";
        c-name: ?"name" ## "_Init"
      end;

      define C-function "update-" ## ?name
        parameter context :: "<" ## ?name ## "-context>";
        parameter data :: <C-string>;
        parameter length :: <C-int>;
        c-name: ?"name" ## "_Update"
      end;

      define C-function "final-" ## ?name
        parameter hash :: <C-unsigned-char*>;
        parameter context :: "<" ## ?name ## "-context>";
        c-name: ?"name" ## "_Final"
      end;

      define class "<" ## ?name ## ">" (<hash>)
        inherited slot digest-size = ?digest-size;
        inherited slot block-size = ?block-size;
      end;

      define method make (class == "<" ## ?name ## ">", #next next-method,
                          #rest rest, #key, #all-keys) => (hash :: "<" ## ?name ## ">")
        let result = next-method();
        let ctx = "init-" ## ?name ();
        result.context := ctx;
        result
      end;

      define method update-hash (hash :: "<" ## ?name ## ">", input :: <byte-string>) => ()
        "update-" ## ?name (hash.context, as(<C-string>, input), input.size)
      end;

      define method digest (hash :: "<" ## ?name ## ">") => (result :: <byte-vector>)
        let res = make(<byte-vector>, size: ?digest-size);
        let storage = make(<C-unsigned-char*>, element-count: ?digest-size);
        "final-" ## ?name (storage, hash.context);
        for (i from 0 below ?digest-size)
          res[i] := as(<byte>, storage[i]);
        end;
        destroy(storage);
        res;
      end;

      define function ?name (input :: <byte-string>) => (result :: <byte-vector>)
        let ctx = make("<" ## ?name ## ">");
        update-hash(ctx, input);
        digest(ctx)
      end
}
end;

