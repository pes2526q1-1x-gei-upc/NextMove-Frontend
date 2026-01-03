import 'package:dartz/dartz.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/company.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/dataproviders/promoted_companies_provider.dart';

class PromotedCompaniesRepository {
  final PromotedCompaniesProvider promotedCompaniesProvider;
  PromotedCompaniesRepository({PromotedCompaniesProvider? promotedCompaniesProvider})
    : promotedCompaniesProvider = promotedCompaniesProvider ?? PromotedCompaniesProvider();

  Future<Either<Failure, List<Company>>> getPromotedCompanies() async {
    try {
      final companiesData = await promotedCompaniesProvider
          .getPromotedCompanies();
      final companies = companiesData != null
          ? companiesData.map((company) {
              final translatedJson = {
                ...company,
                'location': company['ubicacion'],
                'name': company['nombre'],
                'description': company['descripcion'],
              };
              translatedJson.remove('ubicacion');
              translatedJson.remove('nombre');
              translatedJson.remove('descripcion');
              return Company.fromJson(translatedJson);
            }).toList()
          : <Company>[];
      return Right(companies);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(UnknownFailure());
    }
  }
}
