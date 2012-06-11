class V8::Conversion
  module Proc

    def to_v8
      return v8_template.GetFunction()
    end

    def v8_template
      unless @v8_template && @v8_template.weakref_alive?
        template = V8::C::FunctionTemplate::New()
        template.SetCallHandler(InvocationHandler.new, V8::C::External::New(self))
        @v8_template = WeakRef.new(template)
      end
      return @v8_template.__getobj__
    end

    class InvocationHandler
      def call(arguments)
        context = V8::Context.current
        proc = arguments.Data().Value()
        length_of_given_args = arguments.Length()
        args = ::Array.new(proc.arity < 0 ? length_of_given_args : proc.arity)
        0.upto(args.length - 1) do |i|
          if i < length_of_given_args
            args[i] = context.to_ruby arguments[i]
          end
        end
        puts
        context.to_v8 proc.call(*args)
      rescue Exception => e
        warn "unhandled exception in ruby #{e.class}: #{e.message}"
        nil
      end
    end
  end
end