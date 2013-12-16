class A
  def b
    module_eval(<<-EOS)
      def a
        puts 'sa'
      end
    EOS
  end
end
a = A.new
a.b
a.a
