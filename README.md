weasel-spring-mybatis<br />
=====================<br />
前言<br />
<br />
<br />
这是一个基本Spring项目的mybatis的封装包。该包主要封装了对数据库的一些通用CURD操作和数据库的连接。项目基于mybatis-3.2.1<br />
<br />
<br />
功能<br />
一 通用CRUD数据库操作。通过MybatisRepository接口和MybatisOperations提供了一些通用的CURD数据库操作。<br />
二 分页插件。能过PagePlugin提供自动分页，目前支持MySQL和PostgreSQL数据库的分页。如果需要更多的数据库支持，用户可以实现Dialect接口来实现。<br />
三 合并mybatis配置文件。默认情况下，mybatis的配置文件只能有一个，所有mybatis的配置都需要配置在该配置文件下。但有些时候，我们需要在多个文件中配置mybatis。虽然这种情况很少见，但的确存在。可以通过提供的MyBatisSqlSessionFactoryBean代替org.mybatis.spring.SqlSessionFactoryBean。该功能处于测验性阶段。<br />
四 读写分离。通过DynamicRWDataSourceProxy提供读写分离代理，适用于一个读库和一个写库的使用场景。<br />
五 多数据源读写分离。通过DynamicMultiRWDataSourceProxy提供多数据源的读写分离代理，适用于多个读库和多个写库的使用场景。<br />
六 读写分离插件。通过RWPlugin提供自动读写分离。<br />
七 自定义读写库。用户可以通过DataSourceHolder自定义在执行sql语句前使用读库还是写库。如果用户想在读库中执行该语句，可以调用DataSourceHolder的静态方法useRead来切换。如果用户想在写库中执行该语句，可以调用DataSourceHolder的静态方法useWrite来切换。当用户通过DataSourceHolder指定了读写库，本次sql执行RWPlugin的自动路由将不起作用。<br />
<br />
<br />
依赖包<br />
<br />
<br />
要连接数据库，首先要将数据库厂商的连接实现依赖到项目中，在这个包中没有依赖该实现包，需要使用者在自己的应用中依赖。<br />
mysql的依赖配置<br />
<br />
<br />
&lt;dependency&gt;<br />
<span style="white-space:pre">	</span>&lt;groupId&gt;mysql&lt;/groupId&gt;<br />
<span style="white-space:pre">	</span>&lt;artifactId&gt;mysql-connector-java&lt;/artifactId&gt;<br />
<span style="white-space:pre">	</span>&lt;version&gt;5.1.36&lt;/version&gt;<br />
&lt;/dependency&gt;<br />
<br />
<br />
postgresql的依赖配置<br />
&lt;dependency&gt;<br />
<span style="white-space:pre">	</span>&lt;groupId&gt;org.postgresql&lt;/groupId&gt;<br />
<span style="white-space:pre">	</span>&lt;artifactId&gt;postgresql&lt;/artifactId&gt;<br />
<span style="white-space:pre">	</span>&lt;version&gt;9.4-1202-jdbc42&lt;/version&gt;<br />
&lt;/dependency&gt;<br />
<br />
<br />
<br />
<br />
配置<br />
<br />
<br />
一 分页插件配置<br />
&nbsp; 在mybatis配置文件&lt;plugins&gt;节点下添加以下配置:<br />
<span style="white-space:pre">	</span>&lt;plugin interceptor=&quot;com.weasel.mybatis.PagePlugin&quot;&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;SQL_REGULAR&quot; value=&quot;.*?queryPage.*?&quot;/&gt;<br />
<span style="white-space:pre">		</span>&lt;!-- &lt;property name=&quot;DIALECT&quot; value=&quot;com.weasel.mybatis.dialect.impl.MySQLDialect&quot;/&gt; --&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;DIALECT&quot; value=&quot;com.weasel.mybatis.dialect.impl.PostgreSQLDialect&quot;/&gt;<br />
<span style="white-space:pre">	</span>&lt;/plugin&gt;<br />
<br />
<br />
二 读写分离插件配置<br />
&nbsp; &nbsp; 在mybatis配置文件&lt;plugins&gt;节点下添加以下配置:<br />
&nbsp; &nbsp; &lt;plugin interceptor=&quot;com.melon.framework.mybatis.RWPlugin&quot;/&gt;<br />
<br />
<br />
三 双数据源的读写分离配置<br />
&nbsp; &nbsp;在spring配置文件中先配置读数据和写数据源:<br />
&nbsp; &nbsp;&lt;bean id=&quot;master&quot; class=&quot;com.mchange.v2.c3p0.ComboPooledDataSource&quot;<br />
<span style="white-space:pre">		</span>destroy-method=&quot;close&quot;&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;driverClass&quot; value=&quot;${r.jdbc.dirverClass}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;jdbcUrl&quot; value=&quot;${r.jdbc.url}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;user&quot; value=&quot;${r.jdbc.username}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;password&quot; value=&quot;${r.jdbc.password}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;autoCommitOnClose&quot; value=&quot;false&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;initialPoolSize&quot; value=&quot;10&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxPoolSize&quot; value=&quot;30&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;minPoolSize&quot; value=&quot;10&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxIdleTime&quot; value=&quot;1800&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxStatements&quot; value=&quot;1000&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;idleConnectionTestPeriod&quot; value=&quot;8&quot; /&gt;<br />
<span style="white-space:pre">	</span>&lt;/bean&gt;<br />
<span style="white-space:pre">	</span>&lt;bean id=&quot;slave&quot; class=&quot;com.mchange.v2.c3p0.ComboPooledDataSource&quot;<br />
<span style="white-space:pre">		</span>destroy-method=&quot;close&quot;&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;driverClass&quot; value=&quot;${w.jdbc.dirverClass}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;jdbcUrl&quot; value=&quot;${w.jdbc.url}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;user&quot; value=&quot;${w.jdbc.username}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;password&quot; value=&quot;${w.jdbc.password}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;autoCommitOnClose&quot; value=&quot;false&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;initialPoolSize&quot; value=&quot;10&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxPoolSize&quot; value=&quot;30&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;minPoolSize&quot; value=&quot;10&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxIdleTime&quot; value=&quot;1800&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxStatements&quot; value=&quot;1000&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;idleConnectionTestPeriod&quot; value=&quot;8&quot; /&gt;<br />
<span style="white-space:pre">	</span>&lt;/bean&gt;<br />
&nbsp; &nbsp;再在spring配置文件中定义数据源的代理类:<br />
&nbsp; &lt;bean id=&quot;mySqlDataSource&quot; class=&quot;com.concom.mybatis.DynamicRWDataSourceProxy&quot;&gt; &nbsp;&nbsp;<br />
&nbsp; &nbsp; &nbsp; &nbsp; &lt;property name=&quot;readDataSource&quot; ref=&quot;master&quot;/&gt;<br />
&nbsp; &nbsp; &nbsp; &nbsp; &lt;property name=&quot;writeDataSource&quot; ref=&quot;slave&quot;/&gt;<br />
&nbsp; &lt;/bean&gt;<br />
&nbsp; 在spring配置文件中定义SessionFactory:<br />
&nbsp; &lt;bean id=&quot;sqlSessionFactory&quot; class=&quot;org.mybatis.spring.SqlSessionFactoryBean&quot;&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;dataSource&quot; ref=&quot;mySqlDataSource&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;configLocation&quot; value=&quot;classpath:META-INF/mybatis/mybatis.xml&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;mapperLocations&quot; value=&quot;classpath:META-INF/mybatis/mappers/**/*.xml&quot; /&gt;<br />
<span style="white-space:pre">	</span>&lt;/bean&gt;<br />
四 多数据源读写分离配置<br />
&nbsp; 在spring配置文件中先配置读数据和写数据源:<br />
&nbsp; &lt;bean id=&quot;master1&quot; class=&quot;com.mchange.v2.c3p0.ComboPooledDataSource&quot;<br />
<span style="white-space:pre">		</span>destroy-method=&quot;close&quot;&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;driverClass&quot; value=&quot;${r1.jdbc.dirverClass}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;jdbcUrl&quot; value=&quot;${r1.jdbc.url}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;user&quot; value=&quot;${r1.jdbc.username}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;password&quot; value=&quot;${r1.jdbc.password}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;autoCommitOnClose&quot; value=&quot;false&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;initialPoolSize&quot; value=&quot;10&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxPoolSize&quot; value=&quot;30&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;minPoolSize&quot; value=&quot;10&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxIdleTime&quot; value=&quot;1800&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxStatements&quot; value=&quot;1000&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;idleConnectionTestPeriod&quot; value=&quot;8&quot; /&gt;<br />
<span style="white-space:pre">	</span>&lt;/bean&gt;<br />
<span style="white-space:pre">	</span>&lt;bean id=&quot;master2&quot; class=&quot;com.mchange.v2.c3p0.ComboPooledDataSource&quot;<br />
<span style="white-space:pre">		</span>destroy-method=&quot;close&quot;&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;driverClass&quot; value=&quot;${r2.jdbc.dirverClass}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;jdbcUrl&quot; value=&quot;${r2.jdbc.url}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;user&quot; value=&quot;${r2.jdbc.username}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;password&quot; value=&quot;${r2.jdbc.password}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;autoCommitOnClose&quot; value=&quot;false&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;initialPoolSize&quot; value=&quot;10&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxPoolSize&quot; value=&quot;30&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;minPoolSize&quot; value=&quot;10&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxIdleTime&quot; value=&quot;1800&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxStatements&quot; value=&quot;1000&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;idleConnectionTestPeriod&quot; value=&quot;8&quot; /&gt;<br />
<span style="white-space:pre">	</span>&lt;/bean&gt;<br />
<span style="white-space:pre">	</span>&lt;bean id=&quot;slave1&quot; class=&quot;com.mchange.v2.c3p0.ComboPooledDataSource&quot;<br />
<span style="white-space:pre">		</span>destroy-method=&quot;close&quot;&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;driverClass&quot; value=&quot;${w1.jdbc.dirverClass}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;jdbcUrl&quot; value=&quot;${w1.jdbc.url}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;user&quot; value=&quot;${w1.jdbc.username}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;password&quot; value=&quot;${w1.jdbc.password}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;autoCommitOnClose&quot; value=&quot;false&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;initialPoolSize&quot; value=&quot;10&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxPoolSize&quot; value=&quot;30&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;minPoolSize&quot; value=&quot;10&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxIdleTime&quot; value=&quot;1800&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxStatements&quot; value=&quot;1000&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;idleConnectionTestPeriod&quot; value=&quot;8&quot; /&gt;<br />
<span style="white-space:pre">	</span>&lt;/bean&gt;<br />
<span style="white-space:pre">	</span>&lt;bean id=&quot;slave2&quot; class=&quot;com.mchange.v2.c3p0.ComboPooledDataSource&quot;<br />
<span style="white-space:pre">		</span>destroy-method=&quot;close&quot;&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;driverClass&quot; value=&quot;${w2.jdbc.dirverClass}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;jdbcUrl&quot; value=&quot;${w2.jdbc.url}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;user&quot; value=&quot;${w2.jdbc.username}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;password&quot; value=&quot;${w2.jdbc.password}&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;autoCommitOnClose&quot; value=&quot;false&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;initialPoolSize&quot; value=&quot;10&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxPoolSize&quot; value=&quot;30&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;minPoolSize&quot; value=&quot;10&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxIdleTime&quot; value=&quot;1800&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;maxStatements&quot; value=&quot;1000&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;idleConnectionTestPeriod&quot; value=&quot;8&quot; /&gt;<br />
<span style="white-space:pre">	</span>&lt;/bean&gt;<br />
&nbsp; &nbsp; 再在spring配置文件中定义数据源的代理类:<br />
&nbsp; &nbsp; &lt;bean id=&quot;mySqlDataSource&quot; class=&quot;com.concom.mybatis.DynamicMultiRWDataSourceProxy&quot;&gt; &nbsp;&nbsp;<br />
&nbsp; &nbsp; &nbsp; &nbsp; &lt;property name=&quot;readDataSources&quot;&gt;<br />
&nbsp; &nbsp; &nbsp; &nbsp; <span style="white-space:pre">	</span>&lt;list&gt;<br />
&nbsp; &nbsp; &nbsp; &nbsp; <span style="white-space:pre">		</span>&lt;ref bean=&quot;master1&quot;/&gt;<br />
&nbsp; &nbsp; &nbsp; &nbsp; <span style="white-space:pre">		</span>&lt;ref bean=&quot;master2&quot;/&gt;<br />
&nbsp; &nbsp; &nbsp; &nbsp; <span style="white-space:pre">	</span>&lt;/list&gt;<br />
&nbsp; &nbsp; &nbsp; &nbsp; &lt;/property&gt;<br />
&nbsp; &nbsp; &nbsp; &nbsp; &lt;property name=&quot;writeDataSources&quot;&gt;<br />
&nbsp; &nbsp; &nbsp; &nbsp; <span style="white-space:pre">	</span>&lt;list&gt;<br />
&nbsp; &nbsp; &nbsp; &nbsp; <span style="white-space:pre">		</span>&lt;ref bean=&quot;slave1&quot;/&gt;<br />
&nbsp; &nbsp; &nbsp; &nbsp; <span style="white-space:pre">		</span>&lt;ref bean=&quot;slave2&quot;/&gt;<br />
&nbsp; &nbsp; &nbsp; &nbsp; <span style="white-space:pre">	</span>&lt;/list&gt;<br />
&nbsp; &nbsp; &nbsp; &nbsp; &lt;/property&gt;<br />
&nbsp; &nbsp; &lt;/bean&gt;<br />
&nbsp; &nbsp;在spring配置文件中定义SessionFactory:<br />
&nbsp; &lt;bean id=&quot;sqlSessionFactory&quot; class=&quot;org.mybatis.spring.SqlSessionFactoryBean&quot;&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;dataSource&quot; ref=&quot;mySqlDataSource&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;configLocation&quot; value=&quot;classpath:META-INF/mybatis/mybatis.xml&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;mapperLocations&quot; value=&quot;classpath:META-INF/mybatis/mappers/**/*.xml&quot; /&gt;<br />
&nbsp; &lt;/bean&gt;<span style="white-space:pre">	</span><br />
&nbsp;&nbsp;<br />
&nbsp; 注意：在三和四中只需要配置一种场景就可以，理论上多数据源读写分离中读库和写库可以是任意多个。读写分离只是数据源的路由，并没有做到读库和写库的数据同步。要实现读库和写库的数据同步，用户需要自行在数据库级中处理。<br />
&nbsp;&nbsp;<br />
五 mybatis多个配置文件合并配置。<br />
&nbsp; 在spring配置文件中定义SessionFactory:<br />
&nbsp; &lt;bean id=&quot;sqlSessionFactory&quot; class=&quot;com.weasel.mybatis.MyBatisSqlSessionFactoryBean&quot;&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;dataSource&quot; ref=&quot;mySqlDataSource&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;configLocation&quot; value=&quot;classpath:META-INF/mybatis/config/*.xml&quot; /&gt; &nbsp;&lt;!--将所有mybatis配置文件放在config目录下。<br />
<span style="white-space:pre">		</span>&lt;property name=&quot;mapperLocations&quot; value=&quot;classpath:META-INF/mybatis/mappers/**/*.xml&quot; /&gt;<br />
&nbsp; &lt;/bean&gt;<br />
<br />
<br />
六 使用通用CURD。<br />
<br />
<br />
&nbsp; 自定义一个接口，继承MybatisRepository。<br />
&nbsp;public interface UserRepository extends MybatisRepository&lt;Long, User&gt; {<br />
<br />
<br />
}<br />
&nbsp; 自定义一个类，继承MybatisOperations，并实现自定义的接口。<br />
&nbsp;public class UserRepositoryImpl extends MybatisOperations&lt;Long, User&gt; implements UserRepository {<br />
<br />
<br />
}<br />
&nbsp;这样自定义的类就拥有了连接数据库和一些通用的CRUD操作，这些方法来自MybatisOperations，分别有get(ID id);save(T entity);saveBatch(List&lt;T&gt; entities);insert(T entity);update(T entity);delete(T entity); deleteBatch(List&lt;T&gt; entities);query(T entity); queryPage(Page&lt;T&gt; page);方法。<br />
这里值得注意的是save方法，该方法的默认实现是当entity的id值不为空时，认为用户想做的是更新操作，会调用update方法。当entity的id值为空时，认为用户想做的是插入操作，会调用insert方法。<br />
<br />
<br />
&nbsp;mapper文件的配置<br />
<br />
<br />
当然，具体的sql语句该包是不知道的，这个还需要用户自己去定义，sql语句的定义在mapper文件中，具体怎么写mapper文件用户可以参考mybatis的官方文档，下面给一个简单的:<br />
&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; ?&gt;<br />
&lt;!DOCTYPE mapper PUBLIC &quot;-//mybatis.org//DTD Mapper 3.0//EN&quot; &quot;http://mybatis.org/dtd/mybatis-3-mapper.dtd&quot;&gt;<br />
&lt;mapper namespace=&quot;com.weasel.mybatis.test.domain.User&quot;&gt; &nbsp;<br />
<br />
<br />
<span style="white-space:pre">	</span>&lt;resultMap id=&quot;userResultMap&quot; type=&quot;User&quot;&gt;<br />
<span style="white-space:pre">		</span>&lt;id property=&quot;id&quot; column=&quot;id&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;result property=&quot;username&quot; column=&quot;username&quot; /&gt;<br />
<span style="white-space:pre">		</span>&lt;result property=&quot;password&quot; column=&quot;password&quot; /&gt;<br />
<span style="white-space:pre">	</span>&lt;/resultMap&gt;<br />
<br />
<br />
<span style="white-space:pre">	</span>&lt;select id=&quot;getById&quot; resultType=&quot;User&quot;&gt;<br />
<span style="white-space:pre">		</span>select * from users where id =<br />
<span style="white-space:pre">		</span>#{id}<br />
<span style="white-space:pre">	</span>&lt;/select&gt;<br />
<br />
<br />
<span style="white-space:pre">	</span>&lt;insert id=&quot;save&quot; parameterType=&quot;User&quot;&gt;<br />
<span style="white-space:pre">		</span>insert into users<br />
<span style="white-space:pre">		</span>(id,username,password)<br />
<span style="white-space:pre">		</span>values (#{id},#{username},#{password})<br />
<span style="white-space:pre">	</span>&lt;/insert&gt;<br />
<br />
<br />
<span style="white-space:pre">	</span>&lt;update id=&quot;update&quot;&gt;<br />
<span style="white-space:pre">		</span>update users set<br />
<span style="white-space:pre">		</span>username = #{username},<br />
<span style="white-space:pre">		</span>password = #{password}<br />
<span style="white-space:pre">		</span>where id = #{id}<br />
<span style="white-space:pre">	</span>&lt;/update&gt;<br />
<br />
<br />
<span style="white-space:pre">	</span>&lt;select id=&quot;queryPage&quot; resultMap=&quot;userResultMap&quot;&gt;<br />
<span style="white-space:pre">		</span>select id as id,<br />
<span style="white-space:pre">			</span> &nbsp; username as username,<br />
<span style="white-space:pre">			</span> &nbsp; password as password<br />
<span style="white-space:pre">	</span> &nbsp; &nbsp;from users<br />
<span style="white-space:pre">	</span>&lt;/select&gt;<br />
<br />
<br />
&lt;/mapper&gt;<br />
<br />
<br />
mapper文件配置的一些注意事项<br />
这里我们看到namespace使用的是com.weasel.mybatis.test.domain.User，即用户类的包路径，这里是一个约定。如果用户不想这样的约定，在继承MybatisOperations类时可以重写getNamespace，自定义namespace。还有个queryPage，因为分页插件中配置了&lt;property name=&quot;SQL_REGULAR&quot; value=&quot;.*?queryPage.*?&quot;/&gt;，也即当发起带有queryPage字母的，插件都会拦截，为该请求加上分页，这也是一个约定。<br />
因为MybatisOperations中提供了很多通用的方法，但这些方法的sql语句是都没有写的，框架也不知道用户具体的sql语句怎么写，需要用户自己提供。如果用户需要使用所有MybatisOperations提供的方法，应该在mapper文件中定义以下的sql语句，方法和对应的sql语句的id如下:<br />
<br />
<br />
get(ID id) &lt;---------&gt; getById<br />
get(T entity) &lt;---------&gt; get<br />
insert(T entity) &lt;---------&gt; save<br />
update(T entity) &lt;---------&gt; update<br />
delete(T entity) &lt;---------&gt; delete<br />
query(T entity) &lt;---------&gt; query<br />
queryPage(Page&lt;T&gt; page) &lt;---------&gt; queryPage
